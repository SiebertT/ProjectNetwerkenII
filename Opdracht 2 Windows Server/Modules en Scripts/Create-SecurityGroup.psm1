<#
.Synopsis
   Create a Security Group, Assign a manager and fill it with users
.DESCRIPTION
   Using Name, Scope, Path, ManagerName and Description we create a security group. We take the ManagerName and retrieve the managerobject, we then get all the users from the OU the Security group will we located. We then create the security group and fill it up with the users.
.EXAMPLE
   PS C:\Windows\system32> Create-SecurityGroup -Name "Administratie" -Scope Global -Path "OU=Administratie,OU=PFAfdelingen
,DC=Poliforma,dc=nl" -ManagerName "Teus de Jong" -Description "Global group voor de afdeling Administratie"
.Notes
#>
function Create-SecurityGroup
{
    [CmdletBinding()]
    Param
    (
        # What should the name be?
        [Parameter(Mandatory=$true)]
        [String]$Name,
        # What's the scope?
        [Parameter(Mandatory=$true)]
        [ValidateSet('Global','Local')]
        [String]$Scope,
        #Where will it be located
        [Parameter(Mandatory=$true)]
        [String]$Path,
        #Who'll be the manager?
        [String]$ManagerName,
        #A description
        [String]$Description
    )

    Begin
    {
    $Manager = Get-ADUser -Filter {name -eq $ManagerName}
    #Take the users from the OU (The Get-ADUser filter was too limited in filter options, so i had to pipe it to where-object)
    $UsersFromOU = Get-Aduser -filter * | Where-Object {$_.DistinguishedName -Like "*,$Path"}
    $ADGroupPath = "CN=$Name,$Path"
    }
    Process
    {
    #Creating the group
    New-ADGroup -Name $Name -GroupScope $Scope  -ManagedBy $Manager.DistinguishedName -Path $Path -Description $Description 
    #Since the manager isnt always a member of the OU we'll add him manually.
    Add-ADGroupMember -Identity $ADGroupPath -Members $Manager
    foreach($User in $UsersFromOU){
    #Add the users from the OU
    Add-ADGroupMember -Identity $ADGroupPath -Members $User
    }
   
    }
    End
    {
    }
}