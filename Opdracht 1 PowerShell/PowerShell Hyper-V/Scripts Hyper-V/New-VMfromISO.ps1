#requires -version 3.0

<#
.Synopsis
 Create a Hyper-V virtual machine from an ISO file.
.Description
This script This script requires the Convert-WindowsImage.ps1 script which you can download from Microsoft:
  
  http://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f

The default location for the script is C:\Scripts or edit this script file accordingly. 

The script will create a virtual memory with disk, memory and processor specifications. The VHDX file will be created and Convert-WindowsImage will apply the specified Windows image from the ISO. You can use the -ShowUI parameter for a GUI to create the VHDX file, select the ISO and apply the image.

.Parameter Name
The name of your new virtual machine.
.Parameter Path
The path to store your new virtual machine. The default is the server default location.
.Parameter ISOPath
The name and path to the ISO file.
.Parameter DiskName
The name of your new virtual disk. Include the VHD or VHDX extension.
.Parameter DiskPath
The folder for the new virtual disk. The default is the server default location for disks.
.Parameter Size
The size of the new virtual disk file.
.Parameter Memory
The amount of memory for the new virtual machine.
.Parameter Switch
The name of the virtual switch for the new virtual machine.
.Parameter ProcessorCount
The number of processors for the new virtual machine.
.Parameter Edition
The name of the Windows image from the ISO.
.Parameter Unattend
The filename and path of an unattend.xml file to be inserted into new virtual disk.
.Parameter ShowUI
Run the Convert script using the ShowUI parameter. You will be prompted to re-enter the path you specified for the new virtual disk. You might also need to manually remove the virtual drive that is created. DO NOT use this parameter if running this script in a remote PSSession.
.Example
PS C:\> $iso = "G:\iso\en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_x64_dvd_x15-59754.iso"
PS C:\> $newParams=@{
 Name = '2008Web'
 DiskName = 'WebDemo-01.vhdx'
 ISOPath = $Iso
 Edition = "ServerWeb"
 Size = 10GB
 Memory = 1GB
 Switch = "Work Network"
 ProcessorCount = 2
}
PS C:\> c:\scripts\new-vmfromiso.ps1 @newparams

This example creates a hashtable of parameters to splat to the script which will create a new virtual machine running the Web edition of Windows Server 2008.
.Example
PS C:\> c:\scripts\new-vmfromiso.ps1 -name "DemoVM" -ShowUI

This command will launch the script and create a virtual machine called DemoVM using all of the default settings. The convert GUI will displayed.

.Example
PS C:\> invoke-command {c:\scripts\new-vmfromiso.ps1 -name Dev01 -diskname Dev01_C.vhdx -isopath f:\iso\windows2012-x64.iso -edition serverstandardcore -verbose} -comp SERVER01

This command will remotely run this script on SERVER01 to create the desired virtual machine. This script and the Microsoft script have to reside on the remote server.
.Notes
Last Updated: June 18, 2014
Version     : 2.0

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.Link
New-VM

#>

[cmdletbinding(DefaultParameterSetName="Manual",SupportsShouldProcess)]

Param(
[Parameter (Position = 0,Mandatory,
HelpMessage = "Enter the name of the new virtual machine")]
[ValidateNotNullorEmpty()]
[string]$Name,

[ValidateNotNullorEmpty()]
[string]$Path = (Get-VMHost).VirtualMachinePath,

[Parameter(ParameterSetName="Manual",Mandatory,HelpMessage="Enter the path to the ISO file")]
[ValidateScript({Test-Path $_ })]
[string]$ISOPath,

[Parameter(ParameterSetName="Manual",Mandatory,HelpMessage="Enter the name of the install edition, e.g. Windows Server 2012 R2 SERVERSTANDARD")]
[ValidateNotNullorEmpty()]
[string]$Edition,

[Parameter(ParameterSetName="Manual",Mandatory,HelpMessage="Enter the file name of the new VHD or VHDX file including the extension.")]
[ValidateNotNullorEmpty()]
[string]$DiskName,

[Parameter(ParameterSetName="Manual",HelpMessage="Enter the directory name of the new VHD file.")]
[ValidateNotNullorEmpty()]
[string]$DiskPath=(Get-VMHost).VirtualHardDiskPath,

[Parameter(ParameterSetName="Manual")]
[ValidateScript({$_ -ge 10GB})]
[int64]$Size = 20GB,

[Parameter(ParameterSetName="Manual")]
[ValidateScript({Test-Path $_ })]
[string]$Unattend,

[ValidateScript({$_ -ge 256MB})]
[int64]$Memory = 1GB,

[ValidateNotNullorEmpty()]
[string]$Switch = "Work Network",

[ValidateScript({$_ -ge 1})]
[int]$ProcessorCount = 2,

[Parameter(ParameterSetName="UI")]
[switch]$ShowUI
)

#!!! DEFINE THE PATH TO THE CONVERT-WINDOWSIMAGE.PS1 SCRIPT !!!
$convert = "c:\scripts\Convert-WindowsImage.ps1"

if (-Not (Test-Path -Path $convert)) {
  Write-Warning "Failed to find $convert which is required."
  Write-Warning "Please download from:"
  Write-Warning " http://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f"
  Write-Warning "and try again."
  #bail out
  Return
}

#region creating the VHD or VHDX file
if ($pscmdlet.ParameterSetName -eq 'UI') {

if ($pscmdlet.ShouldProcess("ShowUI")) {
  &$convert -showUI
  
  Write-Warning "You may need to manually use Dismount-DiskImage to remove the mounted ISO file."
  $ok= $False
  do {
  [string]$vhdPath = Read-Host "`nWhat is the complete name and path of the virtual disk you just created? Press enter without anything to abort"

  if ($vhdPath -notmatch "\w+") {
    Write-warning "No path specified. Exiting."
    Return
  }
  
  if (Test-Path -Path $vhdPath) {
    $ok = $True
  }
  else {
    Write-Host "Failed to verify that path. Please try again." -ForegroundColor Yellow
  }

  } Until ($ok)
  } #should process
}
else {
#manually create the VHD
#region Convert ISO to VHD
Write-Verbose "Converting ISO to VHD(X)"

$vhdPath = Join-path -Path $DiskPath -ChildPath $DiskName

#parse the format from the VHDPath parameter value
[regex]$rx = "\.VHD$|\.VHDX$"
#regex pattern is case-sensitive
if ($vhdpath.ToUpper() -match $rx) {
    #get the match and strip off the period
    $Format = $rx.Match($vhdpath.toUpper()).Value.Replace(".","")
}
else {
    Throw "The extension for VHDPath is invalid. It must be .VHD or .VHDX"
    #Bail out
    Return
}

#define a hashtable of parameters and values for the Convert-WindowsImage

$convertParams = @{
SourcePath = $ISOPath
SizeBytes = $size
Edition = $Edition 
VHDFormat = $Format
VHDPath = $VHDPath
ErrorAction = 'Stop'
}

if ($Unattend) {
$convertParams.Add("UnattendPath",$Unattend)
}
Write-Verbose ($convertParams | Out-String)

#define a variable with information to be displayed in WhatIf messages
$Should = "VM $Name from $ISOPath to $VHDPath"

#region -Whatif processing
If ($pscmdlet.ShouldProcess($Should)) {
    Try {
        #call the convert script splatting the parameter hashtable
        &$convert @convertParams
    }
    Catch {
        Write-Warning "Failed to convert $ISOPath to $VHDPath"
        Write-Warning $_.Exception.Message 
    }
} #should process
#endregion

#endregion
}

#endregion

#region Creating the virtual machine
Write-Verbose "Creating virtual machine $Name"
Write-Verbose "VHDPath = $VHDPath"
Write-Verbose "MemoryStartup = $Memory"
Write-Verbose "Switch = $Switch"
Write-Verbose "ProcessorCount = $ProcessorCount"
Write-Verbose "Path = $Path"

#new vm parameters
$newParam = @{
Path = $Path
Name = $Name
VHDPath = $VHDPath
MemoryStartupBytes = $Memory
SwitchName = $Switch
}

New-VM @NewParam | Set-VM -DynamicMemory -ProcessorCount $ProcessorCount -Passthru

#dismount the disk image if still mounted
if ($ISOPath -AND (Get-DiskImage -ImagePath $ISOPath).Attached) {
 Write-Verbose "dismounting $isopath"
 Dismount-DiskImage -ImagePath $ISOPath
}

Write-Verbose "New VM from ISO complete"


#endregion

