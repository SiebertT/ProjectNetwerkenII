#Cheat sheet opdracht 2: Windows Server Deployment met Powershell
----

## Boek 1 hoofdstuk 1 - 4

Als server gebruiken we Windows Server 2012 R2 met een core installatie. Deze server laten we lopen in Virtualbox. Als deze installatie voltooid is maken we een kopie zodat we ter allertijden een nieuwe opzet ter beschikking hebben.


### Disable IPv6 op LanConnectie (in aparte lijnen)

Eerst moeten we een lijst van bindings hebben met alle adapters die mogelijk zijn

	Get-NetAdapterBinding -Name "LanConnectie" |Select-Object Name,DisplayName,ComponentID

Hier zien we dat de ComponentID "ms_tcpip6" is

	Disable-NetAdapterBinding -Name "LanConnectie" -ComponentID ms_tcpip6

Controleren of dit gelukt is:

	Get-NetAdapterBinding -Name "LanConnectie" -AllBindings

Hier zien we bij IPv6 false staan dan.

### Hernoem de Server naar AsSv1

	Rename-Computer -NewName "AsSv1"

### Add-ADDSprreq1 (als 1 script)

```
#Lanconnectie
$ipaddress="192.168.101.11"
$ipprefix="24"
$ipdns="127.0.0.1"
$ipif="16"
Netsh interface set interface name="Ethernet" newname="InternetConnectie"
New-NetIPAddress -IPAddress $ipaddress -PrefixLength $ipprefix -InterfaceIndex $ipif
Set-DnsClientServerAddress -InterfaceIndex $ipif -ServerAddresses $ipdns

#Internetconnectie
$ipaddress="192.168.2.111"
$ipprefix="24"
$ipgw="192.168.2.254"
$ipdns="192.168.2.254"
$ipif="12"
Netsh interface set interface name="Ethernet 2" newname="LanConnectie"
New-NetIPAddress -IPAddress $ipaddress -PrefixLength $ipprefix -InterfaceIndex $ipif -DefaultGateway $ipgw
Set-DnsClientServerAddress -InterfaceIndex  $ipif -ServerAddresses $ipdns
```

### Add-ADFeatures

```
#Install AD DS, DNS and GPMC
start-job -Name addFeature -ScriptBlock {
  Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools
  Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools
  Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools
  Add-WindowsFeature  -IncludeManagementTools dhcp	}
Wait-Job -Name addFeature
```

### CreateNewForest

```
# Create New Forest, add Domain Controller
$domainname = "PoliForma.nl"
$netbiosName = "POLIFORMA"

Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "Win2012" `
-DomainName $domainname `
-DomainNetbiosName $netbiosName `
-ForestMode "Win2012" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```

### Install Remote Access

  Install-WindowsFeature -Name "RemoteAccess"

> Troubleshooting
  > * Get-DNSServerZone
  > * IPconfig /all
  > * Get-ADComputer
  > * Get-ADDomain

```
  Import-Module ServerManager
  Install-WindowsFeature RemoteAccess -IncludeManagementTools
  Add-WindowsFeature -name Routing -IncludeManagementTools
```

### Renamen AD sites

```
Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter "objectclass -eq 'site'" | Rename-ADObject -NewName PFBudel
```

### Add DHCP scope


```
Add-DhcpServerv4Scope -EndRange 192.168.101.130 -Name PFBudel -StartRange 192.168.101.31 -SubnetMask 255.255.255.0 -LeaseDuration 6.00:00:00

```

## Boek 1 Hoofdstuk 5

```
$newname = "PFWS1"
Rename-Computer -NewName $newname -force

Add-Computer -Domainname Poliforma.nl -Credential POLIFORMA\Administrator

Test:
1.	Log in as POLIFORMA/Administrator on the workstation
2.	On PFSV1 run Get-ADComputer -Filter *
3.	-> PFWS1 should be in the list
4.	On PFWS1 Primary Dns Suffix will be Poliforma.nl (ipconfig /all)
5.	Get-DhcpServerv4Lease -ScopeId 192.168.101.0
6.	-> PFWS1.Poliforma.nl should be in the list.

5.3

Set-ADComputer "PFWS1" -Description "Werkstation voor algemene doeleinden." -Location "Wisselend"
Test:
Get-ADComputer "PFWS1" -Properties * | FT Name,DNSHostName,Description,Location -A

Set-ADComputer "PFSV1" -Location "Serverruimte B19"
Test:
 Get-ADComputer "PFSV1" -Properties Location | FT Name,DNSHostName,Location

```

### Boek 1 Hoofdstuk 6

```
#Rename c: Label:
Get-Volume -DriveLetter C | Set-Volume -NewFileSystemLabel PFSV1Syst


#Create the E partition
New-Partition -DriveLetter E -Size 20GB -MbrType IFS -DiskNumber 0
Format:
Get-Partition -DriveLetter E | format-volume
Give it the proper label:
Get-Volume -DriveLetter E | Set-Volume -NewFileSystemLabel PFSV1Appl

#Create volume E,F,G,H and I
CreateNewVolume.ps1

[char]$driveletter = read-host "Give a driveletter"
[uint64]$size = read-host "Give the desired size in MB"
[string]$label = read-host "Give the desired label"
[uint32]$number = read-host "Give the desired disk number"
[Mbrtype]$type = read-host "Give the desired Mbrtype"
[string]$filesystem = read-host "Give the desired filesystem"
[int]$compress = read-host "Compress? 1 for yes 0 for no"
$size= $size*1048576

#Create the partition
New-Partition -DriveLetter $driveletter -Size $size -MbrType $type -DiskNumber $number
#Format
if($compress -eq 1)
{Get-Partition -DriveLetter $driveletter | format-volume -FileSystem $filesystem -Compress}
else
{Get-Partition -DriveLetter $driveletter | format-volume -FileSystem $filesystem}
#Label
Get-Volume -DriveLetter $driveletter | Set-Volume -NewFileSystemLabel $label



#Delete a volume
Get-Partition -DriveLetter I|Remove-Partition

#Defragging
Optimize-voluyme -driveletter Hget

#Setting Quota
fsutil quota enforce F:
fsutil quota Modify F: 90000000 100000000 POLIFORMA\Administrator


#Troubleshooting too little diskspace:
Gitbash in virtualbox:
../VirtualBox/VBoxManage.exe modifyhd 'D:/VirtualBox VMs/The PowerShell Core.vdi' --Resize 160000
(Also possible through standard cmd in windows)
```

### Boek 1 hoofdstuk 7

```
#Viewing the shares

View the Shares contained in shared folder from Computer Management:
>Get-WmiObject -Class Win32_Share

On workstation go to explorer and search for //pfsv1 you will see two shares
Open MMC
Add snagit computer managment local
Go to shared folders you will see  shares.
Now right click computer management and select connect to another computer
Enter PFSV1.Poliforma.nl and press ok
You'll be able to see all the shares on PFSV1 from the workstation

A powershell command to view shares:
>Net view \\pfsv1

#Creating shares
>New-SmbShare -Name PFSV1Data -Path F:\
Test:
>Check //pfsv1 in your workstation the share should be there.
>Get-SmbShare

#Removing shares
>Remove-SmbShare -Name PFSV1Data
Test:
>Get-SmbShare PFSV1Data is no longer there

#Make the folder UserFolders and UserProfiles in F:\
>Set-location f:
>mkdir ./UserFolders
>New-SmbShare -Name UserFolders-Description "Description" -Path F:/UserFolders/

We can also use this script to make a simple share that doesnt involve any permissions:

CreateSimpleShare.ps1

[int]$createfolder = read-host "Should a new folder be created for the share? 1 for yes 0 for no"
if($createfolder -eq 1)
{
[string]$folder = read-host "What's the folders name?"
[string]$location = read-host "Where should it be located? ex. C:\Users\"
Set-Location $location
mkdir ./$folder
$location=$location+$folder
echo "The share location will be: $location"
}
else
{
[string]$location = read-host "Where is the share location? ex. C:\Users\"
}
[string]$name = read-host "What name should the share have?"
[string]$description = read-host "What's the shares description?"
New-SmbShare -Name $name -Description $description -Path $location


#Mapping
Create a network drive
On the workstation run following command:
>net use P: \\PFSV1\UserFolders /yes
>net use Q: \\PFSV1\UserProfiles /yes
>net use R: \\PFSV1\F$ /yes

Disconnect from a network drive:
>net use Q: /d

#Creating shadow copies
On PFSV1:
>vssadmin create shadow /for=F:

```

### Boek 1 Hoofdstuk 8


For this chapter we decided to work with .csv as I find this way more convenient as the labor heavy method as described in the book.

The CSV:

Since we already have a completed GUI version im taking the information from here :
Export csv pfsv1:
CSVDE -f adusers.csv -r  objectClass=user

For this we'll use Charlie Russel's script to import all the users. See the  Import-Users script. This script has been modified for our environment.

Run `Import-Users "AdUsers.csv"` in the /documents folder in PowerShell, where you placed the AdUsers.csv file from our modules and scripts folderon GitHub.

Run the Move-ADUser script

```

#Giving a specific user a Quota entry:
fsutil quota modify F: 90000000 100000000 Mad_Sme
Quota entries on the work station

#Post configuration of the Organizational Units:
Finding the location of the manager: Get-ADUser -Filter {name -eq "Madelief Smets"}

> Set-ADOrganizationalUnit -Identity "OU=Directie,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de directie" -ManagedBy "CN=Madelief Smets,OU=Directie,OU=PFAfdelingen,DC=Poliforma,DC=nl"

> Set-ADOrganizationalUnit -Identity "OU=Staf,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de afdeling Staf" -ManagedBy "CN=Danique Voss,OU=Staf,OU=PFAfdelingen,DC=Poliforma,DC=nl"

> Set-ADOrganizationalUnit -Identity "OU=Verkoop,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de afdeling Verkoop" -ManagedBy "CN=Henk Pell,OU=Directie,OU=PFAfdelingen,DC=Poliforma,DC=nl"

> Set-ADOrganizationalUnit -Identity "OU=Administratie,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de afdeling Administratie" -ManagedBy "CN=Teus de Jong,OU=Directie,OU=PFAfdelingen,DC=Poliforma,DC=nl"

> Set-ADOrganizationalUnit -Identity "OU=Productie,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de afdeling Productie" -ManagedBy "CN=Dick Brinkman,OU=Directie,OU=PFAfdelingen,DC=Poliforma,DC=nl"

> Set-ADOrganizationalUnit -Identity "OU=FabricageBudel,OU=Productie,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de onderafdeling FabricageBudel" -ManagedBy "CN=Peter Carprieaux,OU=Productie,OU=PFAfdelingen,DC=Poliforma,DC=nl"

> Set-ADOrganizationalUnit -Identity "OU=Automatisering,OU=PFAfdelingen,DC=Poliforma,DC=nl" -City "Budel" -Description "OU voor de afdeling Automatisering" -ManagedBy "CN=Jolanda Brands,OU=Directie,OU=PFAfdelingen,DC=Poliforma,DC=nl"


>	Make sure userfolders and userprofilepaths are correct


#Enable Remote desktop:

1) Enable Remote Desktop
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
2) Allow incoming RDP on firewall
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
3) Enable secure RDP authentication
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
```

From <http://networkerslog.blogspot.be/2013/09/how-to-enable-remote-desktop-remotely.html>

Open Remote Desktop Connection on the workstation and connect to PFSV1

### Boek 1 hoofdstuk 9

```
#Adding a printer

Install-WindowsFeature Print-Services

#Installing PFPR1

Since the server core does not support printer drivers were working on workstation for this one

On workstation admin:
>Add-PrinterDriver -Name "HP LaserJet 5200 PS Class Driver"
>Add-PrinterPort -Name "PFPR1Port" -PrinterHostAddress "192.168.101.131"
> Add-Printer -Name "PFPR1" -Comment "Bedient de HP LaserJet 5200" -DriverName "HP LaserJet 5200 PS Class Driver" -PortName "PFPR1Port" -Shared  -Published

#Test:
>Get-Printer

```

On server core:
We imported the printer drivers for windows 2012 and ran the .exe resulting in the HP Universal Printing PCL 5 becoming available. (Also imported all the .inf files from the installation) using the same method as before but using a driver called "HP Universal Printing PCL 5" instead. Using this driver we could host and configure printers on the server core.

Installing printers on a server core is still quite the hassle though. There is no initial printer driver support, some printers require the GUI functionality.

### Boek 1 Hoofdstuk 10

Group Policies:
Making the policy PFGebruikersGPO

```
New-GPO -Name PFGebruikersGPO

Set-GPPermissions -Guid <Guid> -PermissionLevel <GPPermisssionType> -TargetName <string> -TargetType {<Computer> | <User> | <Group>}
```

> Lijn hierboven aanpassen a.d.h.v. de requirements.

https://technet.microsoft.com/en-us/library/ee461038.aspx

## Boek 2 Hoofdstuk 1

To view the localgroups in Powershell:

	Net LocalGroup

To go further in the tree:

	Net LocalGroup Administrators

To view global groups:

	Net group

To go further in the tree:

	Net Group 'Domain admins'

Find out more on the users:

	Get-ADUser -filter {name -eq 'administrator'} -Properties MemberOf

On Groups:

	Get-ADGroup -Filter {name -eq "domain users"} -Properties Memberof

Domaincontroller:

	Get-ADDomainController

Now we'll create security groups. The groups are filled with the members of the OU IT inhabits. Aswell as a manager from another OU.

Here we'll use module Create-SecurityGroup.psm1


	PS C:\> Create-SecurityGroup -Name "Directie" -Scope Global -Path "OU=Directie,OU=PFAfdelingen,DC=Poliforma,dc=nl" -ManagerName "Madelief Smets" -Description "Global group voor de afdeling Directie"

	PS C:\> Create-SecurityGroup -Name "Verkoop" -Scope Global -Path "OU=Verkoop,OU=PFAfdelingen,DC=Poliforma,dc=nl" -ManagerName "Henk Pell" -Description "Global group voor de afdeling verkoop"

	PS C:\> Create-SecurityGroup -Name "Administratie" -Scope Global -Path "OU=Administratie,OU=PFAfdelingen,DC=Poliforma,dc=nl" -ManagerName "Teus de Jong" -Description "Global group voor de afdeling Administratie"

	PS C:\> Create-SecurityGroup -Name "Automatisering" -Scope Global -Path "OU=Automatisering,OU=PFAfdelingen,DC=Poliforma,dc=nl" -ManagerName "Jolanda Brands" -Description "Global group voor de afdeling verkoop"

	PS C:\> Create-SecurityGroup -Name "Staf" -Scope Global -Path "OU=Staf,OU=PFAfdelingen,DC=Poliforma,DC=nl" -ManagerName "Danique Voss" -Description "Global group voor de afdeling Staf"

	PS C:\> Create-SecurityGroup -Name "Productie" -Scope Global -Path "OU=Productie,OU=PFAfdelingen,DC=Poliforma,DC=nl" -ManagerName "Dick Brinkman" -Description "Global group voor de afdeling Productie"

	PS C:\> Create-SecurityGroup -Name "FabricageBudel" -Scope Global -Path "OU=FabricageBudel,OU=Productie,OU=PFAfdelingen,DC=Poliforma,DC=nl" -ManagerName "Peter Carprieaux" -Description "Global group voor de onderafdeling FabricageBudel"

##Boek 2 Hoofdstuk 2

Password Policy:

	> New-ADFineGrainedPasswordPolicy -Name "PassNeverExpires" -ComplexityEnabled $true -Description "Users password will never Expire" -DisplayName "PassNeverExpires" -MaxPasswordAge 0

	> Add-ADFineGrainedPasswordPolicySubject -Identity "PassNeverExpires" -Subject "CN=Loes Heijnen,OU=Staf,OU=PFAfdelingen,DC=Poliforma,DC=nl"

Test:

	> Get-ADUserResultantPasswordPolicy -Identity "CN=Loes Heijnen,OU=Staf,OU=PFAfdelingen,DC=Poliforma,DC=nl"

Change the default policy:

	Set-ADDefaultDomainPasswordPolicy -Identity "DC=Poliforma,DC=nl" -MaxPasswordAge 2.00:00:00.0

We set here the format to Days:Hours:Minutes:Seconds.FractionsOfASecond

Run this to see MaxPassWordAge:

	Get-ADDefaultDomainPasswordPolicy

Changing the lockout settings to:

- Treshold of 2 attempts
- Reset counter of 2 minutes
- Lockout duration of 3 minutes

    >Set-ADDefaultDomainPasswordPolicy -Identity "DC=Poliforma,DC=nl" -LockoutDuration 0:3 -LockoutObservationWindow 0:2 -LockoutThreshold 2

Back to proper Lockout settings:

	> Set-ADDefaultDomainPasswordPolicy -Identity "DC=Poliforma,DC=nl" -LockoutDuration 1:00 -LockoutObservationWindow 0:50 -LockoutThreshold 4

##Boek 2 Hoofdstuk 3

Remote Desktop:

Configured here before.

Make Fons Willemsen part of the Domain Admins group:

	>$fons = Get-ADUser -Filter {name -eq "Fons Willemsen"}
	>Add-ADGroupMember -Identity "Domain Admins" -Members $fons

Test:

	>Get-ADGroupMember -Identity "Domain Admins"


We can now log in with Fons Willemsen his account and use remote desktop

As Fons Willems make Jolanda Brands member of the groupos Account Operators, Backup Operators, Print operators and Server Operators

	> $j = Get-ADUser -Filter {name -eq "Jolanda Brands"}
	> Add-ADGroupMember -Identity "Account Operators" -Members $j
	> Add-ADGroupMember -Identity "Backup Operators" -Members $j
	> Add-ADGroupMember -Identity "Print Operators" -Members $j
	> Add-ADGroupMember -Identity "Server Operators" -Members $j

Test:

	>Get-ADPrincipalGroupMembership -Identity $j

Jolanda Brands can now also access the Server Core but with Limited Access.

Try to make Peter Carprieaux member of the groupos Account Operators, Backup Operators, Print operators and Server Operators as Jolanda Brands.

This will fail since Jolanda Brands isn't part of the Domain Admin group


	>$P = Get-ADUser -Filter {name -eq "Peter Carprieaux"}

	> Add-ADGroupMember -Identity "Account Operators" -Members $p
	> Add-ADGroupMember -Identity "Backup Operators" -Members $p
	> Add-ADGroupMember -Identity "Print Operators" -Members $p
	> Add-ADGroupMember -Identity "Server Operators" -Members $p


Test:

	>Get-ADPrincipalGroupMembership -Identity $p

Allow him to log in on the server machine:

	$p |Set-ADUser -LogonWorkstations $null
