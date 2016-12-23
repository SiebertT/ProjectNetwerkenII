#requires -version 4.0
#requires -modules Hyper-V
#requires -RunAsAdministrator

Function Get-VHDInfo {
<#
.Synopsis
Get virtual disk information.
.Description
This command will get virtual disk information for a given set of virtual machines on a Hyper-V server. The default is all virtual machines.

The command uses PowerShell remoting to verify that the virtual disk file exists.

.Example
PS C:\> Get-VHDInfo -VMName chi-fp02 -Computername chi-hvr2
Getting disk file information on chi-hvr2 for virtual machine chi-fp02


VM                      : CHI-FP02
Path                    : C:\VM\CHI-FP02\Virtual Hard Disks\CHI-FP02_C.vhdx
VhdFormat               : VHDX
VhdType                 : Dynamic
Size                    : 21474836480
FileSize                : 20069744640
FragmentationPercentage : 5
ParentPath              : 
Attached                : True
Verified                : True
ComputerName            : CHI-HVR2

VM                      : CHI-FP02
Path                    : C:\vhd\chi-fp02-disk2.vhdx
VhdFormat               : VHDX
VhdType                 : Dynamic
Size                    : 10737418240
FileSize                : 306184192
FragmentationPercentage : 7
ParentPath              : 
Attached                : True
Verified                : True
ComputerName            : CHI-HVR2
.Example
PS C:\> Get-VHDInfo -computername chi-hvr2 | export-csv c:\work\DiskReport.csv -notype

Get virtual disk information for all VMs on server CHI-HVR2 and export to a CSV file.

.Example
PS C:\scripts> Get-VHDInfo -Computername chi-hvr2 | sort FragmentationPercentage -Descending | select -first 3 -Property VM,Path,Frag*,*size
Getting disk file information on chi-hvr2 for virtual machines *


VM                      : Dev02
Path                    : C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\Dev02_C.vhdx
FragmentationPercentage : 33
Size                    : 21474836480
FileSize                : 5641338880

VM                      : CHI-FP02
Path                    : C:\vhd\chi-fp02-disk2.vhdx
FragmentationPercentage : 27
Size                    : 10737418240
FileSize                : 306184192

VM                      : CHI-FP02
Path                    : C:\VM\CHI-FP02\Virtual Hard Disks\CHI-FP02_C.vhdx
FragmentationPercentage : 15
Size                    : 21474836480
FileSize                : 20069744640

Get the 3 most fragmented VHD files.
.Example
PS C:\scripts> Get-VHDInfo -comp chi-hvr3 | where {! $_.verified}
Getting disk file information on chi-hvr3 for virtual machines *


VM                      : Dev01
Path                    : D:\VHD\Dev01_C.vhdx
VHDFormat               : VHDX
VHDType                 : UNKNOWN
Size                    : 0
FileSize                : 0
FragmentationPercentage : 
ParentPath              : 
Attached                : False
Verified                : False
Computername            : CHI-HVR3

Identify VHD files that are referenced but missing.

.Notes
Last Updated: June 20, 2014
Version     : 2.0

.Link
Get-VHD

#>
[cmdletbinding()]
Param(
[Parameter(Position=0)]
[ValidateNotNullorEmpty()]
[alias("Name")]
[string[]]$VMName="*",
[ValidateNotNullorEmpty()]
[string]$Computername = $env:computername
)

Write-Host "Getting disk file information on $computername for virtual machines $VMName" -ForegroundColor Cyan

Try {
$disks = Get-VM -name $VMname -computername $computername -ErrorAction Stop | 
Select-Object -ExpandProperty harddrives | Select-Object VMName,Path,Computername 
}
Catch {
    Throw $_

}

#continue if there are some disks
if ($disks) {

    #create a temporary PSSession to the remote computer so we can test the path
    Try {
        if ($computername -ne $env:computername) {
          Write-Verbose "Creating a temporary PSSession top $computername"
          $sess = New-Pssession -ComputerName $Computername -ErrorAction Stop
        }
    }
    Catch {
        #failed to create PSSession
        Throw $_
        #bail out
        Return
    }
    Write-Verbose "Processing disks..."
    foreach ($disk in $disks) {
 
     Write-Verbose ("VM {0} : {1}" -f $disk.VMName,$disk.path)

     Try {
        $disk | Get-VHD -ComputerName $computername -ErrorAction Stop | 
        Select-Object -property @{Name="VM";Expression={$disk.vmname}},
        Path,VHDFormat,VHDType,Size,FileSize,FragmentationPercentage,ParentPath,Attached,
        @{Name="Verified";Expression={
        if ($computername -eq $env:computername) {
          Test-Path -path $_.path
        }
        else {
          $diskpath = $_.path
          Invoke-command -ScriptBlock {Test-Path -path $using:diskpath} -session $sess
         }
        }},Computername
    } #Try
    Catch {
     write-warning "Failed to find $($disk.path)"
     #write a mostly empty custom object for the missing file
     $hash=[ordered]@{
         VM = $disk.VMName
         Path = $disk.path
         VHDFormat = (split-path $disk.path -Leaf).split(".")[1].ToUpper()
         VHDType = "UNKNOWN"
         Size = 0
         FileSize = 0
         FragmentationPercentage=$null
         ParentPath=$null
         Attached=$False
         Verified=$False
         Computername =$disk.Computername
         }
         [pscustomobject]$hash
     } #catch
    } #foreach disk
}

#clean up
if ($sess) { 
    Write-Verbose "Removing PSSession"
    Remove-PSSession $sess 
}
} #end function