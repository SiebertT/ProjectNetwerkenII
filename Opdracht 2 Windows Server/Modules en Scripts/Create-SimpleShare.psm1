<#
.Synopsis
   Creates a unconfigured share
.DESCRIPTION
   Using variables Location, Name and description we create a share. If the location need to yet be created we can assign true to the CreatePath variable.
.EXAMPLE
   PS C:\> Create-SimpleShare -Location H:\ -Name ExampleShare -Description "This is an example"

Name         ScopeName Path Description
----         --------- ---- -----------
ExampleShare *         H:\  This is an example
.EXAMPLE
PS C:\> Create-SimpleShare -Location H:\NewPath\ -Name ExampleShare -Description "This is an example" -CreatePath $true


    Directory: H:\


Mode         LastWriteTime Length Name
----         ------------- ------ ----
d----  9-11-2015     17:02        NewPath

AvailabilityType      : NonClustered
CachingMode           : Manual
CATimeout             : 0
ConcurrentUserLimit   : 0
ContinuouslyAvailable : False
CurrentUsers          : 0
Description           : This is an example
EncryptData           : False
FolderEnumerationMode : Unrestricted
Name                  : ExampleShare
Path                  : H:\NewPath
Scoped                : False
ScopeName             : *
SecurityDescriptor    : O:SYG:SYD:(A;;0x1200a9;;;WD)
ShadowCopy            : False
ShareState            : Online
ShareType             : FileSystemDirectory
Special               : False
Temporary             : False
Volume                : \\?\Volume{e1bbecf6-fa3f-11e1-93fb-080027037fd8}\
PSComputerName        :
PresetPathAcl         : System.Security.AccessControl.DirectorySecurity



#>
function Create-SimpleShare
{
    [CmdletBinding(confirmImpact='High')]
    Param
    (
        # Param1 help description
        
        [Parameter(Mandatory=$true,
                    HelpMessage="Where is the location?")]
        [string]$Location,
        [Parameter(Mandatory=$true,
                    HelpMessage="What's the name of the share?")]
        [string]$Name,
        [Parameter(Mandatory=$true,
                    HelpMessage="What's the share's description?")]
        [string]$Description,
        [Parameter(Mandatory=$false,
                    HelpMessage="Does the path to share have to be created?")]
        [string]$CreatePath
    )

    Begin{}
    Process
    {
    If($CreatePath)
    {
    mkdir $Location
    }
    New-SmbShare -Name $Name -Description $Description -Path $Location
    }
    End{}
}