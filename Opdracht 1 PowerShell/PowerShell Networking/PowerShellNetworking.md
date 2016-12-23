# Samenvatting Windows PowerShell Networking Guide - Ed Wilson

## Source

[Klik hier om het eBook te bekijken of te downloaden.](https://www.gitbook.com/book/devopscollective/windows-powershell-networking-guide/details)

## Intro
Created by Microsoft's "The Scripting Guy," Ed Wilson, this guide helps you understand how
PowerShell can be used to manage the networking aspects of your server and client
computers.

By learning to use Windows PowerShell, network administrators quickly gain access to information from Windows Management Instrumentation, Active Directory and other essential sources of information.

There are 2 flavors of PowerShell, one that is integrated into the console and one Integrated Scripting Environment (ISE). You are free to use either one for whatever u prefer.

## Admin rights and normal user
Even when on an admin user, opening PowerShell in the standard way will not give you admin rights for your commands. By right-clicking and telling PowerShell to run as admin will give you these rights.

> Note: As a first step in troubleshooting, check admin rights.

## PowerShell cmdlets
cmdlets are made out of verbs, a dash and nouns
For example:

    Get + - + Disk => Get-Disk

## Network connection profile for each interface
    Get-NetConnectionProfile

## Information about keyboard layout
	Get-Culture or Get-C + tab
## Information about UI language
	Get-UICulture or Get-UI + tab
## Configuring culture or UICulture
	set-Culture or set-UICulture
> In case you are struggling with the keyboard layout when logging in

## Get the date
	Get-Date

## Generating a random number
	Get-Random or Get-R + tab

> Handy to pick random winner, generate random names, random amount of time for performance testing

## Parameters and positional parameters
	Get-Process powershell
This piece of code shows the specific process named powershell, if you look up the help for the cmdlet Get-Process you can see that -name is placed at position 1. This means that the word 'powershell' is a parameter that is placed at the implied -name position. For other cmdlets you may have to write the parameter out.

> Refer to the help files to see what parameters are called and what is positional, as this can be confusing at first.

## Range as a parameter for RNG
	Get-R + tab + 21
By default, the cmdlet has the -Maximum parameter, this means you will get a random number between 0 to 20. The last number is never reached so don't forget +1.

To call for an explicit range, use the following parameters

	Get-Random -Maximum 21 -Minimum 1

## Parameter sets
It is inefficient to use this script 5 times in order to get 5 winners.

There is a Get-Random parameter set for Maximum and Minimum and a set for counts.

The parameter set for the count requires a collection of objects. An Array of numbers is stated as 1..10 (1 to 10). 

This translates to:

	Get-Random -InputObject(1..10) -Count 5
Now we get 5 random numbers between 1 and 10.

## Command line utilities
It is possible to execute CMD lines of code in PowerShell too.
For example:

	ipconfig

The same information can be gained from a PowerShell command, this is more complex but the information gained is not simply text, it is an object which can be manipulated further and more than just text.

CMD lines and PowerShell language can also be combined for more efficiency

    1..3 | % {gpupdate ; sleep 300}

This line will refresh Group Policy 3 times and wait for 5 minutes between refreshes.

## Working with help options
Firstly it's important to update the help files on your system, so you're sure you get the most current information.

	Update-help -Force

Make sure you've admin rights on your PowerShell console and that you're connected to the internet.

	-Online

This switch can be used to open the help page in your default browser.


	Save-Help

Can be used to download help from the internet, the update-help cmdlet can then point to the network share for the files.

## Working with modules
To get a look at the commands of a module use this syntax

	get-command-moduleNetadapter

If you get an error, you might need to load the module manually

	import-moduleNetadapter

If you want to know the nr of commands in the module, you can pipeline the results to the Measure-Object cmdlet

	get-command-modulenetadapter | Measure-Object

## Working with Network Adapters
Firstly, you need to know the version of the OS you're running, this will limit or expand what u can do.

Secondly, you need to realize that the utilized tools are different if you're working locally or remotely.

Thirdly, use the tool that works best for you. PowerShell ISE is recommended.

List all Network Adapters + see if running

	Get-NetAdapter

If you want to get deeper into detail of an adapter use this:

	Get-NetAdapter -Name ethernet|Format-List *

For a more detailed view of the properties listed here

	Get-NetAdapter -Name ethernet | select adminstatus, MediaConnectionState

To get information of the adapters where admin status is up

	Get-NetAdapter|whereadminstatus-eq"up"

To find network adapters sniffing the network

	Get-NetAdapter| ? PromiscuousMode -eq $true

To find which network adapters have the client for Microsoft Networks bound

	Get-NetAdapter |
	Get-NetAdapterBinding |
	where {$\_.enabled -AND$\_.displayname -match 'client'}

## Enabling and disabling network adapters

	Get-NetAdapter |Where status -ne up | Enable-NetAdapter

	Get-NetAdapter |? status -ne up | Disable-NetAdapter


## Check if network adapters disabled

	Get-NetAdapter| ? status-ne up | Disable-NetAdapter -Confirm:$false

## Enable a specific network adapter

	Enable-NetAdapter -Name ethernet -Confirm:$false

## Disable network adapters with y/n prompt for every adapter

	Get-NetAdapter -Name vethernet\* | Disable-NetAdapter

## Renaming the network adapter

	Get-NetAdapter -Name Ethernet|Rename-NetAdapter -NewName MyRenamedAdapter

## Renaming the network adapter with output of command

	Get-NetAdapter -Name Ethernet|Rename-NetAdapter -NewName MyRenamedAdapter -PassThru

## Renaming the network adaptor with output and wildcard

	Get-NetAdapter -Name Ether\* |Rename-NetAdapter -NewName MyRenamedAdapter -PassThru

> This is handy in case you don't want to type the entire adapter name, or if they have similar names you can retrieve them as well.

## Finding connected network adapters (show 'up' physical adapters)

	Get-NetAdapter -physical| where status -eq 'up'

## Finding the physical network adapters

	Get-NetAdapter -Physical

to get the 'up' physical adapters

	Get-NetAdapter -Physical| where status -eq 'up'

## Getting and setting the adapter power management variables

	Get-NetAdapter -InterfaceIndex 4 | Set-NetAdapterPowerManagement -WakeOnMagicPacket Enabled

> Index4 is the index of the interface so you don't have to type the name or description

> If you use the PowerShell ISE the last part of the command is shown with all possible variables as you can see below

![](https://i.gyazo.com/b4436032465ec32d287bf5f02cd4c9db.png)

## Configuring all your network adapter power management settings in 1 line

	Set-NetAdapterPowerManagement -Name ethernet -ArpOffload Enabled -DeviceSleep OnDisconnect Disabled -NSOffload Enabled -WakeOnMagicPacket Enabled -WakeOnPattern Enabled -Passthru

> -Passthru outputs the configuration object so that you can see that all is as intended.

To do this on multiple computers, you can use the New-CimSession cmdlet for the remote connections. A variable is used to specify the remote connection.

    $session = New-CimSession -ComputerName edlt
    Set-NetAdapterPowerManagement -CimSession $session -name ethernet -ArpOffload Enabled -DeviceSleepOnDisconnect

> You need to be administrator in your PowerShell to execute this command

## Get Network Statistics

	Get-NetAdapterStatistics

For a specific adapter, use

	Get-NetAdapter -ifIndex 12| Get-NetAdapterStatistics

To get all the information possible out of this command, use

	Get-NetAdapter -ifIndex 12| Get-NetAdapterStatistics | format-list\*

