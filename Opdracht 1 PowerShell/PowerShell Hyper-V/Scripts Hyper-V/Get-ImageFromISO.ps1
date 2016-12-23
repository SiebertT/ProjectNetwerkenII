#requires -version 4.0
#requires -module Storage,DISM


Function Get-ImageFromISO {

<#
.Synopsis
List Windows editions from an ISO file.
.Description
This command will list the available Windows images from an ISO file.
.Example
PS C:\> Get-ImageFromISO G:\iso\en_windows_server_2012_x64_dvd_915478.iso


ISOPath     : G:\iso\en_windows_server_2012_x64_dvd_915478.iso
Name        : Windows Server 2012 SERVERSTANDARDCORE
Description : Windows Server 2012 SERVERSTANDARDCORE
Index       : 1
SizeMB      : 6862

ISOPath     : G:\iso\en_windows_server_2012_x64_dvd_915478.iso
Name        : Windows Server 2012 SERVERSTANDARD
Description : Windows Server 2012 SERVERSTANDARD
Index       : 2
SizeMB      : 11444

ISOPath     : G:\iso\en_windows_server_2012_x64_dvd_915478.iso
Name        : Windows Server 2012 SERVERDATACENTERCORE
Description : Windows Server 2012 SERVERDATACENTERCORE
Index       : 3
SizeMB      : 6844

ISOPath     : G:\iso\en_windows_server_2012_x64_dvd_915478.iso
Name        : Windows Server 2012 SERVERDATACENTER
Description : Windows Server 2012 SERVERDATACENTER
Index       : 4
SizeMB      : 11440

Generally, the only part of the image name you need is what is in upper case.
.Notes
Last Updated:
Version     : 1.0

.Link
Get-WindowsImage
#>

[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the path to the ISO file.",
ValueFromPipeline,ValueFromPipelineByPropertyName)]
[ValidateScript({ Test-Path -path $_})]
[Alias("FullName")]
[string]$Path
)

Process {
Write-Verbose "Mounting $path as read-only"

$iso = Mount-DiskImage -ImagePath $path -Access ReadOnly -PassThru -StorageType ISO

$drive = "{0}:\" -f ($iso | Get-DiskImage | Get-Volume).DriveLetter

$wimPath = Join-Path -Path $drive -ChildPath "sources\install.wim"

Write-Verbose "Reading image information from $wimPath"

#add the ISO path to the output and make sure to sort by index.
#The image size is also formatted in MB.
Get-WindowsImage -ImagePath $wimPath |
Add-Member -MemberType NoteProperty -Name ISOPath -Value $path -PassThru |
Select ISOPath,@{Name="Name";Expression={$_.ImageName}},
@{Name="Description";Expression={$_.ImageDescription}},
@{Name="Index";Expression={$_.ImageIndex}},
@{Name="SizeMB";Expression={$_.ImageSize /1MB -as [int]}} | Sort Index

Write-Verbose "Dismounting disk image"

$iso | Dismount-DiskImage

} #end process

} #end function

