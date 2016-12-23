#requires -version 3.0
#requires -module Hyper-V

Function Get-ObsoleteVHD {
<#
.Synopsis
Get orphaned or obsolete virtual disk files.
.Description
This command will search a directory for VHD or VHDX files that are not attached to any existing Hyper-V virtual machines. The default behavior is to search the default virtual hard disk path on the local computer.

The function uses PowerShell remoting to query paths on remote computers. 
.Example
PS C:\> get-obsoletevhd -computer chi-hvr2


    Directory: C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---         6/26/2013   8:51 PM 9399435264 Win8.1PreviewBase.vhdx

Getting unused virtual disk files on server CHI-HVR2 in the default location.
.Example
PS C:\> get-obsoletevhd -computer chi-hvr2 -Path c:\vhd


    Directory: C:\vhd


Mode                LastWriteTime      Length Name
----                -------------      ------ ----
-a---          5/9/2014   1:59 PM 10842275840 Essentials.vhdx
                                           
An unused file in a different location on server CHI-HVR2.
.Example
PS C:\> get-obsoletevhd -path g:\vhds -computer Server01 | measure -sum Length | Select Count,@{Name="SizeGB";Expression={$_.sum/1GB}}

Count                              SizeGB
-----                              ------
   11                    82.3568634986877

This example is finding all unused virtual disk files in G:\VHDS on SERVER01 and then calculating how much disk space they are consuming.

.Notes
Last Updated: June 25, 2014
Version     : 1.0

.Link
Get-VHD
#>

[cmdletbinding()]

Param(
[Parameter(Position=0)]
[ValidateNotNullorEmpty()]
#use the value for -Computername is specified, otherwise the local computer
[string]$Path=(Get-VMHost -computername ( &{if ($computername) { $computername} else { $env:computername}})).VirtualHardDiskPath,
[Alias("CN")]
[ValidateNotNullorEmpty()]
[string]$Computername=$env:computername
)

Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
Write-Verbose "Searching for obsolete virtual disk files in $Path on $($Computername.ToUpper())"

#initialize an array to hold file information
$files = @()

Try {
    #get currently used virtual disk files
    Get-VM -computername $computername -ErrorAction Stop | Select -ExpandProperty HardDrives |
    Get-VHD -ComputerName $computername  |
    foreach { 
        $files+=$_.path
        if ($_.parentPath) {
         $files+=$_.parentPath
        } #if path
    } #foreach
} #try
Catch {
    Throw $_
    #bail out
    
}

if ($files) {
    #filter out duplicates
    $diskfiles = $files | Sort | Get-Unique -AsString

    write-verbose "Attached files"
    $diskfiles | Write-Verbose

    write-verbose "Orphaned files in $path"
    $sb = {
     Param($path)
     if (Test-Path -path $Path) {
     dir -Path $path -file -filter *.vhd? -Recurse
     }
     else {
        Write-Warning "Failed to find path $path on $($env:computername)"
     }
    }

    $found = if ($Computername -ne $env:computername) {
      Invoke-Command -ScriptBlock $sb -ComputerName $computername -HideComputerName -ArgumentList @($path)
    }
    else {
       &$sb $path
    }
    if ($found) {
        Write-Verbose "Found $($found.count) files"
        $found.fullname | write-verbose 
        $found | where {$files -notcontains $_.fullname}
    }
    else {
        Write-Host "No files found in $path on $computername" -ForegroundColor Red
    }
} #if files were found
Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
} #end function
