# Samenvatting Secrets of PowerShell Remoting

[Klik hier om dit ebook te downloaden of te lezen.](https://www.gitbook.com/book/devopscollective/secrets-of-powershell-remoting/details)
## Enable Remoting

`Enable-PSRmoting`

Indien er problemen zijn met de firewall exceptions die niet buiten public runnen gebruik:
`Enable-PSRemoting -SkipNetworkProfileCheck`

Ook de flag `-force` kan problemen verhelpen.
## Kijken naar aantal connecties
`Get-PSSessionConfiguration`
## Remoting naar 1 PC
`Enter -PSSession -computerName MijnComputer`

Sluit de connectie met:
`Exit-PSSession`
## Remoting naar meerdere PC's
#### Commando's naar meerdere PC's
`Invoke-Command -computername MijnComputer, PC2 -scriptBlock { Get-Service }`

Get-Service is hier het commando dat naar alle PC's wordt gestuurd.

(Maximum 32 computers, limiet verhoogbaar op eigen risico met de parameter `-ThrottleLimit`)
#### Scripts uitvoeren op meerdere PC's
`Invoke-Command -computername PC1,PC2 -filePath c:\Scripts\Task.ps1`

## Persistente Sessies
Steeds heropenen en sluiten van connecties is niet efficiënt, het is beter om een sessie aan te maken en daarin te werken.
#### Aanmaken van de sessie
`$PersistenteSessie = New-PSSession -ComputerName PC1`

Nu gebruik je ipv `-computername` bij `Invoke-Command` de parameter `-Session` samen met de naam die je aan de sessie hebt gegeven.

`Invoke-Command -Session $PersistenteSessie -scriptBlock { $test = 1 }`

#### Sluiten van de sessie
`Remove-PSSession -Session $PersistenteSessie`

## Remoting Scripts
Indien je remote commando's of scripts wil runnen in een script, gebruik steeds `Invoke-Command`, anders zal het script lokale resources gebruiken.
Dit is de correcte aanpak:

```
$session = New-PSSession -ComputerName SERVER2  
Invoke-Command -session $session -ScriptBlock { C:\RemoteTest.ps1 }
```
## Remote Connectie: HTTP / HTTPS
Indien je een beveiligde connectie wil runnen zal je certificates moeten aanmaken en een paar third party tools moeten gebruiken. Een gewone remote connectie kan ook aan de hand van HTTP.

#### Maken en gebruiken van certificates.
Maken van certificates gaat niet binnen powershell volgens het boek, ze raden een extern programma aan, [DigiCert](http://DigiCert.com/util)

Na het maken van een certificate (CSR) sla je het op in een tekstbestandje.
![](http://puu.sh/sfP1S/7f402c0cce.jpg)

Deze kan je uploaden op verscheidene websites waaronder [deze](http://www.watchguard.com/help/docs/wsm/xtm_11/en-us/content/en-us/certificates/cert_complete_signing_req_c.html) om een (CA) te bekomen.

Hierna open je mmc.exe en en selecteer je "Add/Remove Snap-ins" en voeg je het certificate toe. Vervolgens volg je de wizard.

![](http://puu.sh/sfPbd/8afb99345a.png)

Na dat je de thumbprint hebt ontvangen van het certificate na het volgen van de wizard kunnen we de HTTPS listener opzetten.

![](http://puu.sh/sfPnO/4475a9f0dc.png)

#### HTTPS Listener

Run het volgende commando in powershell of cmd.

    Winrm create winrm/config/Listener?Address=\*+Transport=HTTPS @{Hostname="xxx";CertificateThumbprint="yyy"}

Enkele pointers bij dit commando:

* Sterretje is de wildcard, je kan dit vervangen door een IP adres. Nu luistert de listener naar alle lokale IP-adressen.
* In de plaats van 'xxx' zet je de exacte computernaam inclusief domein als dat er is.
* In de plaats van 'yyy' zet je de thumbprint die je eerder kopieerde, deze mag spaties bevatten.

Ook moet je een windows firewall exception maken als je dit gebruikt, dit kan aan de hand van:

    New-WSManInstance winrm/config/Listener -SelectorSet @{Address='\*';
    Transport='HTTPS'} -ValueSet @{HostName='xxx';CertificateThumbprint='yyy'}

##### Testen van de listener.

Flush eerst je DNS met:

    Ipconfig /flushdns

Connectie maken a.d.h.v. HTTPS:

    Enter-PSSession -computerName DCA -credential COMPANY\Administrator -UseSSL

Modifcaties die je kan toepassen op een Enter-PSSession met SSL:

*  -SkipCACheck, skippen met het controleren of het certificate van eent trusted CA komt.
*  -SkipCNCheck, skpipen met het controleren of het certificate van de juiste machine komt.

Met deze parameters kan je een sessie maken als volgt:

    $option = New-PSSessionOption -SkipCACheck -SkipCNCheck
    Enter-PSSession -computerName DCA -sessionOption $option
        -credential COMPANY\Administrator -useSSL

**Waarschuwing:** Als je deze parameters gebruikt zal je geen errors krijgen maar is het hele punt van SSL weg. Dit laat een enorm gat op vlak van security en gebruik deze dus enkel op eigen risico.

#### Certificate Authentication
Na het maken van een listener kunnen we certificates authenticeren voor een secure remote connection te maken.
Op de client computer zal je het volgende moeten doen (Als je Micrsoft Enterprise CA gebruikt, anders volg de instructies van je CA provider.):

* Run certmgr.msc en open "Certificates - Current User"
* Rechterklik "Personal" en selecteer "all tasks" -> "Request New Certificate"
* In het "Enrollment" venster druk "Next" en vervolgens klik "Active Directory Enrollment Policy" aan en klik terug op "Next", selecteer de juiste template en klik op "Enroll"

Vervolgens op de remote pc, run Powershell als admin en gebruik volgend commando:

    Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true

Nu importeren we de client certificate op de remote pc, open "mmc.exe" en voeg terug met Snap-ins het certificate toe, volg terug de wizard.

Nu rest ons enkel de mapping te maken op de remote pc. Run in Powershell als admin:

    Get-ChildItem -Path cert:\LocalMachine\Root
    Get-ChildItem -Path cert:\LocalMachine\Root  

Dit geeft ons de thumbprint.

![](http://puu.sh/sfQQH/d0c8c1b836.png)

Nu kunnen we het volgende commando runnen om de mapping te vervolledigen:

    New-Item -Path WSMan:\localhost\ClientCertificate -Credential (Get-Credential) -Subject <userPrincipalName> -URI \* -Issuer <CA Thumbprint> -Force

#### Connecting met Certificate Authentication

Nu alles klaar is, kunnen we connecten. Eerst halen we de Thumbprint terug op met:

    Get-ChildItem -Path Cert:\CurrentUser\My

Run vervolgens `Invoke-Command` of `New-PSSession` met optie `CertificateThumbprint`, ook te bezien in volgende afbeelding:

![ ](http://puu.sh/sfR3m/d1a9714aff.png)



#### Toevoegen van host in Trustedhosts (Zonder SSL)

Bij een remote connectie zal de pc een connectie proberen maken met de host, echter kan deze enkel slagen met een SSL of als de host in de lijst van Trustedhosts staat. Daarom voegen we deze eerst toe.
Vervang * door het juiste ip adres, of laat het staan zodat alle hosts toegelaten worden. (Niet aangeraden!)

`winrm set winrm/config/client @{TrustedHosts="*"}`

 of

 `Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value '*'`

#### Verbinden met de remote host
 `Enter-PSSession -Computername 192.168.5.5 -Credential RemoteHostNaam\Administrator`

 Voor crossdomein, gebruik steeds de hostnaam!

## Second Hopping
 (Werkt enkel op Vista en Server 2008 of later.)
 Remote connectie maken vanaf een remote pc, lukt niet door een authenticatiefout. Gebruik volgende commandos.

#### Snelle manier:
 Op de originerende PC:

 `Enable-WSManCredSSP -Role Client -Delegate name`

 Op eerste hop:

 `Enable-WSManCredSSP -Role Server`

#### Tragere manier (In geval van fouten):
 Op client:

 `Set-Item WSMAN:\localhost\client\auth\credssp -value $true`

 Op 1e hop:

 `Set-Item WSMAN:\localhost\service\auth\credssp -value $true`

 Verder moet je de delegatie van credentials toelaten. Dit doe je via:
 `Computer Configuration > Policies > Administrative Templates > System > Credential Delegation > Allow Delegation of Fresh Credentials`

 Je geeft de namen van de machines of een wildcard in.

##   Endpoints ##
 Met `Get-PSSessionConfiguration` kunnen we de endpoints zien van een PC waar we kunnen op connecteren.
 Als je met een endpoint wilt connecteren dat niet de default is geef je een parameter mee adhv `-ConfigurationName`, bvb:

 `Enter-PSSession -ComputerName PC1 -ConfigurationName 'microsoft.powershell32'`

 Je kan deze endpoints ook zelf maken. Toepassingen hiervoor zijn:
 * Scripts autorunnen als iemand connnect
 * Commando's limiteren op een endpoint
 * Accountbeheer op een connectiepunt

Een endpoint maak je met het commando:
`New-PSSessionConfigurationFile`
Dit commando heeft vele extra parameters, slechts 1 is verplicht, `-Path` om het pad van het bestand (dat tevens moet eindigen op .PSSC) mee te geven. De rest is optioneel en bekijkbaar met het commando `help New-PSSessionConfigurationFile` te runnen.

Als je een configuration file hebt aangemaakt kan je deze vervolgens registreren met `Register-PSSessionConfiguration`. Ook hier is het lezen van de help binnen PowerShell aangeraden voor de vele optionele parameters.

Een goed voorbeeld van een custom endpoint aanmaken staat op [deze link](https://devopscollective.gitbooks.io/secrets-of-powershell-remoting/content/manuscript/working-with-endpoints-aka-session-configurations.html)  bij figuur 3.6.

### Security Loophole bij endpoints

Een kleine nota nog bij het maken van custom session configuration files, er is een loophole waarbij men codeblokken kan injecteren en zo de restricties kan omzeilen. Men kan dit uitschakelen door te verbieden van "full-language" te gebruiken bij het zetten van de language-mode. Zet daarom indien nodig steeds de language parameter op `NoLanguage` of `RestrictedLanguage` (deze laat nog basic operators toe en filtering).

## Troubleshooting en Diagnosis
Troubleshooting gebeurt aan de hand van logs. Je moet de logs eerst laten genereren tussen 2 punten aan de hand van volgende commandos.

Eerst importeer je de log module.
`import-module PSDiagnostics`

Starten van log:
`Enable-PSWSManCombinedTrace`
Als de log succesvol gestart is krijg je als output `The command completed succesfully`.

Opvragen van de log:
`get-winevent microsoft-winrm/operational`

Standaard logs zijn zeer onleesbaar. Je kan deze structureren en leesbaar maken aan de hand van een intern microsoft tool. Je kan instructies en het tool en script vinden in [deze zip.](http://www.concentratedtech.com/Documents/psdiagnostics.zip)

#### Standaard methodologie bij Troubleshooting
1. Test remoting met default configuratie.
2. Probeert te connecteren met bvb Windows Explorer in een shared map om te testen op globale problemen.
3. Installeer een telnet client op de host en probeer te connecteren met `telnet machine_name:5985`. Als dit niet werkt is er een basic connectieprobleem zoals een gesloten poort dat eerst moet opgelost worden.
4. Gebruik het commando `Test-WSMan`.

## Session Management
Sessies geopend met `Invoke-Command` of `Enter-PSSession` worden achteraf automatisch verwijderd door PowerShell.

Wat ook mogelijk is, is het zelf maken van een sessie adhv `New-PSSession`.

Echter kan men ook een lopende sessie tijdelijk verlaten door het gebruiken van dit commando: `Disconnect-PSSession`. Men kan dan terug connectie maken wanneer men wenst met `Connect-PSSession`. Beide commando's hebben een verplicht sessieobject als parameter nodig.

Na het gebruiken van `Disconnect-PSSession` blijft PowerShell draaien op de target machine, dit kan onveilig zijn. Daarom geeft men vaak een PSSessionOption-Object mee als parameter bij het maken van een sessie.

Men kan de default options aan passen of een custom PSSessionOption-Object aanmaken met `PSSessionOption`. In dit optie bestand kan je veel parameters instellen waaronder timeout en dergelijke die de veiligheid van de sessie garanderen.

## Security omtrent Remoting en PowerShell

Powershell en remoting wordt vaak gezien als een zwaktepunt in de Security, echter niets is minder waar als deze goed geconfigureerd zijn. Standaard laat de configuratie enkel Administrators toe om te connecteren en men kan adhv endpoints nog verder delegeren. Hieronder enkele standpunten die duidelijk maken dat PowerShell geen security issue is.

* PowerShell noch remoting zijn een backdoor.

PowerShell beschouwt elk commando als uitgevoerd door de gebruiker. Een gebruiker zal dus nooit buiten zijn permissies kunnen stappen aan de hand van PowerShell. Sterker, men kan de permissies verbeteren adhv PowerShell. Je kan een admin beperken in zijn kracht en opties aan de hand van een custom endpoint.

* PowerShell remoting is niet optioneel

PowerShell remoting runt op de achtergrond zelf in de gui vanaf Windows 2012. Alle server management taken gaan door PowerShell remoting.

* Remoting tranfert of bewaart geen inloginfo.

Alle inloggegevens worden standaard geloost door Kerberos, een authenticatieprotocol dat geen gegevens tranfert over het netwerk maar vertrouwt op encryptie adhv paswoorden. Verder werkt Kerberos met tokens, en schrijft deze nooit iets op harde schijf per design, enkel op RAM niveau worden tijdelijk dingen opgeslagen. Men kan ook deze security verlagen naar een basic niveau of werken met een certificate based encryptie indien dit nodig is.

* Remoting gebruikt standaard encryptie

Remoting gebruikt een encryptie voor alle verkeer, dit kan ook verhoogd worden door HTTPS te gebruiken samen met certificates indien gewenst voor nog betere encryptie.

* Remoting gebruikt dubbele authenticatieprotocol

Er wordt zowel authenticatie uitgevoerd bij de host als bij de target. Zo kan men zeker nooit per ongeluk connecteren met een verkeerd doelwit. Dit zorgt ervoor dat je steeds weet wie met je server connecteert en dat je zeker met de echte server connecteert en geen fake node.

## Remoting instellen via Group Policy (Enkel voor Windows Server versies lager dan 2012!)
In Windows Server 2012 staan alle remoting opties standaard geactiveerd. Op oudere versies moeten deze soms geactiveerd worden. Als je Group Policies aanpast, nemen deze pas effect na het herstarten van de pc!

#### Automische configuratie van WinRM Listeners
Default HTTP listener staat niet aan op oudere versies, je kan deze GPO vinden op volgend pad: `Computer Configuration\Administrative Templates\Windows Components\Windows Remote Management (WinRM)\WinRM Service`. Geef vervolgens de gepaste IP adressen in of gebruik wildcards zoals `*`.

#### WinRM Service automatisch starten
Dit moet je enkel toepassen op systemen lager dan Server 2003. Voeg de service toe aan de opstart lijst adhv commando: `Set-Service WinRM -computername $servers -startup Automatic`.

Je kan dit ook via GPO regelen op het pad: `Computer Configuration\Windows Settings\Security Settings\System Services` en dan vervolgens de service "Windows Remote Management" op `automatic` te zetten.

#### Windows Firewall Exception toevoegen.
Deze stap zal je moeten uitvoeren op elke PC waar Windows firewall aanwezig is.

Navigeer in GPO naar `Computer Configuration\Administrative Templates\Network\Network Connections\Windows Firewall\Domain Profile` en pas vervolgens de policy  "Define inbound port exceptions" aan. Zet de policy aan en voeg de volgende exceptie toe: `5985:TCP:*:enabled:WinRM"`

#### Limieten van GPO

Instellingen in GPO zijn zeer beperkt, de aan te raden aanpak is remoting activeren via GPO en dan via remoting verdere instellingen zoals endpoints etc instellen.
