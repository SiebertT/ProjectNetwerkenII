# Samenvatting: Microsoft Virtual Academy: Powershell
----

## 01 | Don't fear the shell

### Waarom is PowerShell nodig? 

Je kan alle scripts die je scrijft gemakkelijk automatiseren terwijl ze ook werken op oudere systemen. Het probleem met GUI's kan zijn dat je alles manueel moet doen en dat de GUI's van nieuwe/oudere versies te veel gaan verschillen waardoor implementatie ook moeilijker wordt.

Open als administrator -> hiermee kan je veel meer scripts uitvoeren en heb je meer rechten

Customize je powershell door op het powershell logotje te klikken en dan eigenschappen.

cmdlets: 

### Change Directory
set-location c:\  of cd\

### Show files in folder

get-childitem   of  dir

tree

### Clean the PowerShell Window

clear-host	of  cls

### Aliases of commands

get-alias of gal

### Directory

md of mkdir + naam voor aanmaken van directory

### Help

help of man --> voor hulp 

### Network Information

ipconfig /all


## 02 | The Help system

### Update help system: 

update-help -Force

> Always do this first if you're looking for information

### Gebruik maken van help: 

get-help *service*

vb:  get-help get-service
geeft help weer van get-service

met get-verb krijg je alle verbs om te zien welke er gebruikt worden 

get-verbs | measure geeft aantal verbs weer

get-help get-service -Detailed
hier krijg je een meer uitgebreide help, parameters worden ook uitgelegd.

> Meest interessant als je niet goed weet wat te doen met de cmdlet

    get-help get-service -Examples
    get-help get-service -full
    get-help get-service -Online
    get-help get-service -ShowWindow (krijg je in een window de help te zien en kan je aanpassen welke je wilt zien) 

### Copy pasting

selecteer iets rechtklik = copy en linksklik = paste

get-service -Name g*, c* 

je kan via wildcards ook nog kijken welke services er werken, hier dus beginnend met g en c

### Zoeken welke displayname er begint met bit

get-service -DisplayName bit*

get-service bits

-Name moet er niet bijstaan, dit toont de service bits

### Tabbing through the parameters

met tab kan je door de cmd scrollen bv get-(tab) -> krijg je alles met get- 

get-help * eventlog* 

### toont alle about_... paginas 

help about_* 


## 03 | The pipeline: getting connected & extending the shell

### Syntax

character: | 

vb: 
get-service -name bits | stop-service 

gaat beide uitvoeren te gelijk (dus neemt bits en gaat deze stoppen) 

### Pipeline exports

get-service | export-csv -Path c:\service.csv

notepad c:\service.csv
import-csv c:\service.csv



get-service | converto-html -Property name,status | out-file c:\test.htm


get-service | stop-service -whatif
(whatif toont wat er kan) 

get-service | stop-service -confirm
(voor bevestiging)


pipeline wordt gebruikt om achter elkaar opdrachten uit te voeren (eerst dit, dan dat, erna dat, ...)



## 04 | Extending the shell

### Show modules

get-module (toont de lopende modules)

get-Module -ListAvailable 
(toont alle beschikbare modules) 

get-help *add*  (toont alle mogelijkheden met add) 

### Snap-ins

get-PPSnapin -Registered

Add-PSSnapin sql*

> Snap-ins contain cmdlets for certain tasks, they can be imported

### Adding Modules

get-command -Module sql*

import-module act*

get-command -Module Act*

import-module servermanager

gtm -module server*

### Adding Windows Features

get-windowsFeature

add-windowsfeature telnet-client, telnet-server -restart


##05 | Object for the admin


### Get Service objects starting with b

get-service b* (je krijgt service objects)

### get processes where greater than 
get-process | where handles -gt 900 | sort handles

gps | where {$_.handles -ge 1000}
(met $_handles nemen we elk object stoppen we in de $_ en gaan hun handles vergelijken met greater then 1000, als ze groter zijn worden ze weergegeven)

## Get name and status out of service objects
 
get-service | select-object name, status (geeft name en status weer van service objecten) 

sort-object kunnen we sorten (-descending) 

##06 | The pipeline deeper

In de help full staat er bij de parameters "Accept pipeline input" als kan false of true zijn. De pipeline gaat dus afhankelijk van het commando al dan niet werken.

	get-service | stop-process 

>kan niet samen werken omdat ze niet hetzelfde zijn, maar het werkt wel door pipeline

	get-ADComputer 

> werkt niet vraagt om meer informatie om op te filteren)

> in showwindow kan je ook zoeken op byvalue om te zien welke parameters pipeline input true zijn.


	get-adcomputer -filter * | select -Property name, @{n = 'Computername'; e={$_.name}} | gm

Hier ga je alle AD pcs opvragen a.d.h.v. de `-filter *` die met de pipeline select de computername gebruikt. De laatste pipeline dient om de member hieruit te nemen.

	get-ADComputer -filter * | gm

Dit dient voor het zelfde, maar zonder selectie op naam.

	get-help WmiObject -full 

>kijken naar de help pagina van WmiObject, hier kan je geen pipeline input voor krijgen

	Get-Wmiobject -class win32_bios -ComputerName (Get-Adcomputer -filter *)

> De haakjes dienen als alternatieve oplossing aangezien directe pipeline niet mogelijk is

	Get-ADComputer -filter * | Select -Property name 

>Als je enkel de names wilt zien

	Get-Wmiobject -class win32_bios -ComputerName (Get-ADComputer -filter * | select -ExpandProperty name) 

> Aangezien je niet rechtstreeks een pipeline kan gebruiken, dit is een andere manier

nog makkelijker: 

	Get-Wmiobject -class win32_bios -ComputerName (Get-ADComputer -filter *).name


## 07 | The power in the shell - Remoting

	Enter-PSSession -ComputerName dc 

> nu zitten we op computer dc --> `hostname` intikken zien we de hostname

	invoke-command -ComputerName dc,s1,s2 {restart-computer} 

>via remote gaan we nu voor de 3 machines ze restarten, tussen {} meegeven wat ze moeten doen

Als we dingen willen weergeven van andere computers dan is dit een representatie van de computer, niet het object dus hierop kunnen niet rechtstreeks methodes uitvoeren

	Get-Windowsfeatures 

>zien welke features er zijn + geinstalleerd zijn

	Install-WindowsFeature windowsPowershellWebAccess

	get-help * pswa *

	install-PswaWebApplication
 
	Add-PswaAuthorizationRule -ConfigurationName


start iexplore `https://pwa/pswa`

>gaan we via browser naar inlogscherm waar we kunnen kiezen op welke computer we willen aanmelden, dit is ook voor als je devices hebt zonder powershell

Een snel scriptje: 

	get-service -name bits (in notepad en opslaan als .ps1)

en dan via powershell script runnen ./naam


## Getting prepared for automation

create certificate:  `new selfSignedCertificate`

	get-psdrive 

>hier zien we cert drive

	dir Cert:\CurrentUser -Recurse -CodeSigningCert -OutVariable a 

Als we een script willen uitvoeren moeten deze signed zijn  

	Set-AuthenticodeSignature -Certificate  $cert -FilePath .\Test.ps1

nu kan je het script wel runnen 



Variables voor in scripts: 

    $MyVar = hello
    $MyVar = Get-service bits
    
    $MyVar (tonen wat in myvar zit)
    
    $MyVar | gm
    
    $MyVar.status
    $MyVar.stop()
    $MyVar.refresh() 

> altijd eerst refreshen om iets dat veranderd is weer te geven.
    

	$var=read-host "Enter a computername" 

> vraagt een computernaam die jij kunt ingeven daarna veranderd var naar de computernaam

	write-warning "please.. dont do that"

	write-error "Error"


## Automation in scale - Remoting

	icm -comp dc {$var = 2}

	icm -comp dc {write-output $var} --

> geeft geen output meer weer

	$sessions = New-PSSession -ComputerName dc

	Get-PSSession 

	icm -Sessions $sessions {$var=2}
	icm -Session $sessions {$var} 

> via een session geeft dit wel de output terug

	Measure-command { icm -ComputerName dc {Get-Process}} 

> kijken hoe snel het gaat

	Measure-command { icm -session  $sessions {Get-Process}} 

>moet sneller zijn met sessions

    $servers = 's1', 's2'
    $servers | foreach{ start iexplore http://$_} (geeft geen pagina weer) 
    $s = new-PSSession -ComputerName $servers (nu zijn s1 en s2 sessions)

    icm -Session $s {Install-WindowsFeature web-server} 

>installeren van webservers op s1 en s2 veel sneller via sessions

als we nu kijken naar de http dan zien we wel iets

notepad c:\default.htm (hier zin schrijven voor uitvoer te krijgen)

	 $servers | foreach{copy-item c:\default.htm -Destination \\$_\c$\inetpub\wwwroot} 

> gaan we het notepad default naar de servers schrijven als we dan uitvoeren gaan we onze tekst zien

	$s=New-PSSession -ComputerName dc

	Import-PSSession -session $s -Mocule ActiveDirectory -Prefix remote

	Get-remoteADComputer -filter *

> Je moet niet alles installeren op jouw machine om de commando's te krijgen, je haalt de commando's van die andere machine (importeert ze), gebruikt ze en stuurt ze dan door om op een andere machine uit te voeren (dit kan tussen verschillende machines zijn) 


## Introducing scripting and toolmaking

Powershell ISE 

> hierin worden de mogelijkheden getoont als je begint te typen + heeft kleurtjes

	Get-WmiObject win32_logicaldisk -filter "DeviceID='c:'" 

	Get-WmiObject win32_logicaldisk -filter "DeviceID='c:'" | select freespace

	Get-WmiObject win32_logicaldisk -filter "DeviceID='c:'" | Select @{n='freegb' ; e={$_.freespace / 1gb -as [int]}}  

> geeft weer hoeveel vrije ruimte er nog is op je c schijf

voor op eender welke computer:

	$ComputerName='localhost'
 
	Get-wmiobject -computername $ComputerName -class win32_logicaldisk -filter "DeviceID= 'c'"

Met parameters te maken: 

	param(
		$ComputerName='localhost',
		$Bogus
 	)

	Get-wmiobject -computername $ComputerName -class win32_logicaldisk -filter "DeviceID= 'c'"

Uitvoeren van script: 

	.\diskinfo.ps1 -computername 'localhost'

	get-help .\diskinfo.ps1

Met cmdletBinding() + verplicht maken van parameters : 

	<#
	.Synopsis
	This is the short explonation
	.Description
	This is the long description
	.Parameter computername
	This is for remote computers
	.Example
	diskinfo -computername remote
	THis is for a remote computer
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True)]
		[string[]]$ComputerName,
		$Bogus
 	)

	Get-wmiobject -computername $ComputerName -class win32_logicaldisk -filter "DeviceID= 'c'"

Als we nu get-help .\diskinfo.ps1 doen zien we alles wat we in command geschreven hebben als uitleg. Bij -full zien we nog meer uitleg. 

In de ISE kunnen we direct de Cmdlet inporteren en dan staat alles er direct in en moet je het juist nog invullen.


invoegen van 'function'

function verb - noun 

	<#
	.Synopsis
	This is the short explonation
	.Description
	This is the long description
	.Parameter computername
	This is for remote computers
	.Example
	diskinfo -computername remote
	THis is for a remote computer
	#>

	function Get-diskinfo{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True)]
		[string[]]$ComputerName,
		$Bogus
 	)

	Get-wmiobject -computername $ComputerName -class win32_logicaldisk -filter "DeviceID= 'c'"
	}

Uitvoeren van de function: 

	. .\diskinfo.ps1
	Get-diskinfo -ComputerName dc

je kan dan deze uitvoer in een variable steken om hiermee dan verder te werken: 

	Get-diskinfo -ComputerName dc -outvariable $a

Save als .psm1 dan hebben we een module.

Om deze module te importeren: 

	Import-Module .\Diskinfo.psm1
	Import-Module .\Diskinfo.psm1 -Forece -Verbose

Nu kunnen we gewoon rechtstreeks Get-diskinfo gebruiken. 

OF 

	$env:PSModulePath -split ";"


Ga niet je modules in de module folder onder Powershell doen in de system folder. Er is een folder onder ducomenten waar je je eigen folders maakt en modules plaatst. (Folder moet naam van module hebben)

	get-help *disk* 

Hiermee vinden we nu ook onze functie die onder onze folder staat. 

Als we nu meerdere functions toevoegen in deze module dan gaan we deze ook kunnen gebruiken. 


Belangrijk in deze filmpjes: 

- Get-help
- Pipiline (meer info in boek Don John - Learn windowspowershell in a month of lunches chapter 9)
- MVA -Scripting Toolmaking
- www.PowerShell.org
- Twitter: #PowerShell
- Twitter: @JSnover


