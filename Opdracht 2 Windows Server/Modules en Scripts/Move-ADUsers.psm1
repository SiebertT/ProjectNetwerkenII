<#
.Synopsis
   Moves users to the location specified in the Csv file
.DESCRIPTION
   We take all the current ADUsers and sort them by name. We then take the Csv file which has the correct locations, if required we create the destinations and then we move the users to their newly assigned location.
.EXAMPLE
   PS C:\Users\Administrator> Move-ADUsers .\adusers.csv
Administrator doesn't need to be moved
Danique Voss has been moved to OU=Staf,OU=PFAfdelingen,DC=PoliForma,DC=nl
Dick Brinkman has been moved to OU=Directie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Dirk Bogert has been moved to OU=Administratie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Doortje Heijnen has been moved to OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Floris Flipse has been moved to OU=FabricageBudel,OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Fons Willemsen has been moved to OU=Automatisering,OU=PFAfdelingen,DC=PoliForma,DC=nl
Guest doesn't need to be moved
Henk Pell has been moved to OU=Directie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Herman Bommel has been moved to OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Jan Smets has been moved to OU=Automatisering,OU=PFAfdelingen,DC=PoliForma,DC=nl
Jolanda Brands has been moved to OU=Directie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Karin Visse has been moved to OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
krbtgt doesn't need to be moved
Loes Heijnen has been moved to OU=Staf,OU=PFAfdelingen,DC=PoliForma,DC=nl
Madelief Smets has been moved to OU=Directie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Niels Smets has been moved to OU=FabricageBudel,OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Peter Carprieaux has been moved to OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Teus de Jong has been moved to OU=Directie,OU=PFAfdelingen,DC=PoliForma,DC=nl
Wiel Nouwen has been moved to OU=Verkoop,OU=PFAfdelingen,DC=PoliForma,DC=nl
Will Snellen has been moved to OU=FabricageBudel,OU=Productie,OU=PFAfdelingen,DC=PoliForma,DC=nl
.EXAMPLE
   PS C:\Users\Administrator> Move-ADUsers -CsvLocation .\adusers2.csv
Administrator doesn't need to be moved
OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
OU=Staf,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Danique Voss has been moved to OU=Staf,OU=ExampleDepartment,DC=PoliForma,DC=nl
OU=Directie,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Dick Brinkman has been moved to OU=Directie,OU=ExampleDepartment,DC=PoliForma,DC=nl
OU=Administratie,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Dirk Bogert has been moved to OU=Administratie,OU=ExampleDepartment,DC=PoliForma,DC=nl
OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Doortje Heijnen has been moved to OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl
OU=ExampleBudel,OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Floris Flipse has been moved to OU=ExampleBudel,OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl
OU=Automatisering,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Fons Willemsen has been moved to OU=Automatisering,OU=ExampleDepartment,DC=PoliForma,DC=nl
Guest doesn't need to be moved
Henk Pell has been moved to OU=Directie,OU=ExampleDepartment,DC=PoliForma,DC=nl
Herman Bommel has been moved to OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl
Jan Smets has been moved to OU=Automatisering,OU=ExampleDepartment,DC=PoliForma,DC=nl
Jolanda Brands has been moved to OU=Directie,OU=ExampleDepartment,DC=PoliForma,DC=nl
Karin Visse has been moved to OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl
krbtgt doesn't need to be moved
Loes Heijnen has been moved to OU=Staf,OU=ExampleDepartment,DC=PoliForma,DC=nl
Madelief Smets has been moved to OU=Directie,OU=ExampleDepartment,DC=PoliForma,DC=nl
Niels Smets has been moved to OU=ExampleBudel,OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl
Peter Carprieaux has been moved to OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl
Teus de Jong has been moved to OU=Directie,OU=ExampleDepartment,DC=PoliForma,DC=nl
OU=Verkoop,OU=ExampleDepartment,DC=PoliForma,DC=nl has been created
Wiel Nouwen has been moved to OU=Verkoop,OU=ExampleDepartment,DC=PoliForma,DC=nl
Will Snellen has been moved to OU=ExampleBudel,OU=Productie,OU=ExampleDepartment,DC=PoliForma,DC=nl

.Notes
#>
function Move-ADUsers
{
    [CmdletBinding(confirmImpact='High')]
    Param
    (
        # Give a link to the Csv location
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$CsvLocation
    )

    Begin{}
    Process
    {
    $currentlocation = Get-ADUser -filter * | Get-ADObject |sort name
    $desiredLocation = Import-CSV $CsvLocation |sort name
    #Loop for all users
    For($i=0;$i -lt $currentlocation.count;$i++)
    {
    $Name = $desiredLocation[$i].name
    If($currentlocation[$i].DistinguishedName -eq $desiredLocation[$i].DistinguishedName)
    {
    echo  "$Name doesn't need to be moved"
    } 
    Else
    {
    #We need to remove the first CN in the DistinguishedName hence we have to remove CN=Employee Name, to do this we take the employee name and add 4 to remove the CN= and ,
    
    $finalLocation = $desiredLocation[$i].DistinguishedName.Substring($Name.length+4)
    $splitDistinguished = $desiredLocation[$i].distinguishedName.Split(",")
    #If the location does not yet exist, create it.
    If(![adsi]::Exists("LDAP://$finalLocation"))
    {
    #Pak de host
    $OUCheck = $splitDistinguished[$splitDistinguished.count-2] + "," + $splitDistinguished[$splitDistinguished.count-1]
    For($j=1;$j -lt $splitDistinguished.count-2 ;$j++)
    {
    $OUCheck2 = $splitDistinguished[$splitDistinguished.count-2-$j] + "," + $OUCheck
    If(![adsi]::Exists("LDAP://$OUCheck2"))
    {
    New-ADOrganizationalUnit -Name $splitDistinguished[$splitDistinguished.count-2-$j].Substring(3) -Path $OUCheck
    echo "$OUCheck2 has been created"
    }
    
    $OUCheck = $OUCheck2
    }
    }
    #We now move the object
    Move-ADObject $currentlocation.DistinguishedName[$i] -TargetPath $finalLocation
    #Display the info so the administrator can confirm
    echo "$Name has been moved to $finalLocation"
    }
}

    }
    End{}
}