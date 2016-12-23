# Samenvatting: THE ALTARO POWERSHELL HYPER-V COOKBOOK

The link to the book can you find here: [Altaro PowerShell Hyper-V Cookbook](http://www.altaro.com/assets/Altaro-PowerShell-Hyper-V-Cookbook.pdf "Altaro PowerShell Hyper-V Cookbook")

## Requirements and setup 

* PowerShell 3.0 
* Hyper-V PowerShell module
* Hyper-V server running Windows Server 2012

Recipes were tested from Windows 8.1 client running the Hyper-V role and a Hyper-V server running Windows Server 2012 R2 (both have PowerShell 4.0)

To do most from your client desktop: Control Panel - Programs, click on "Turn Windows features on or off" and navigate down to "Hyper-V". Check the box for the "Hyper-V module for Windows PowerShell". 

Alternative: install the Remote Server Administration Tools and specify the Hyper-V role. Include the Hyper-V Powershell module. [https://www.microsoft.com/en-us/search/DownloadResults.aspx?q=remote%20server%20administration%20tools](https://www.microsoft.com/en-us/search/DownloadResults.aspx?q=remote%20server%20administration%20tools)

Hyper-V servers have PowerShell remoting enabled. 

Many of the recipes consist of a PowerShell function that resides in a PowerShell script. You must first have a script execution policy that will allow you to run scripts. Then you will need to do source the script file into your PowerShell session.
    
    PS C:\> . .\scripts\New-VMFromTemplate.ps1

**Note:** 
none of these scripts or functions require anything other than the Hyper-V module. 


## Hyper-V Cmdlet Basics
See all of the available cmdlets: 

	Get-Command -Module Hyper-V

Cmdlets can be used in pairs (Get-VM and Start-VM). 
Get a set of virtual machines that meet some criteria and then start them. Gets all virtual machines that start with CHI and that are not running and then starts them. 

	Get-VM chi* | where {$_.state -eq ‘Off’} | Start-VM -AsJob 

Most Hyper-V cmdlets let you specify a remote Hyper-V server using the -Computername parameter. 
	
	Get-VM chi* -ComputerName chi-hvr2 | where {$_.state -eq ‘Off’} | Start-VM -asjob 

Use virtual machines running on the server CHI-HVR2. 

**Note:** PowerShell must be running as Administrator

## Creating a Virtual Machine

cmdlet: 

	New-VM = new virtual machine
	New-VHD = new virtual disks

### Using a Template

Function that will create a virtual machine based on pre-defined type of Small, Medium or Large. To change any of the settings, edit the script.

**explain the parameters of the script**

    .Description
    This script will create a new Hyper-V virtual machine based on a template or hardware
    profile. You can create a Small, Medium or Large virtual machine. You can specify the virtual
    switch and paths for the virtual machine and VHDX files.
    All virtual machines will be created with dynamic VHDX files and dynamic memory. The virtual
    machine will mount the specified ISO file so that you can start the virtual machine and load
    an operating system.

    VM Types:

    Small (default)
     MemoryStartup=512MB
     VHDSize=10GB
     ProcCount=1
     MemoryMinimum=512MB
     MemoryMaximum=1GB

    Medium
     MemoryStartup=512MB
     VHDSize=20GB
     ProcCount=2
     MemoryMinimum=512MB
     MemoryMaximum=2GB

    Large
     MemoryStartup=1GB
     VHDSize=40GB
     ProcCount=4
     MemoryMinimum=512MB
     MemoryMaximum=4GB

    This script requires the Hyper-V 3.0 PowerShell module.

    .Parameter Path
    The path for the virtual machine.

    .Parameter VHDRoot
    The folder for the VHDX file.

    .Parameter ISO
    The path to an install ISO file.

    .Parameter VMSwitch
    The name of the Hyper-V switch to connect the virtual machine to.

    .Parameter Computername
    The name of the Hyper-V server. If you specify a remote server, the command will attempt
    to make a remote PSSession and use that. Any paths will be relative to the remote computer.

    Parameter Start
    FREE VM Backup More Info & Download 7
    Start the virtual machine immediately.


**Script:**

	#requires -version 3.0
    Function New-VMFromTemplate {

    [cmdletbinding(SupportsShouldProcess)]
    Param(
    [Parameter(Position=0,Mandatory,HelpMessage=”Enter the name of your new virtual machine”)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [ValidateSet(“Small”,”Medium”,”Large”)]
    [string]$VMType=”Small”,
    [ValidateNotNullorEmpty()]
    [string]$Path = (Get-VMHost).VirtualMachinePath,
    [ValidateNotNullorEmpty()]
    [string]$VHDRoot=(Get-VMHost).VirtualHardDiskPath,
    [Parameter(HelpMessage=”Enter the path to an install ISO file”)]
    [string]$ISO,
    [string]$VMSwitch = “Work Network”,
    [ValidateNotNullorEmpty()]
    [string]$Computername = $env:COMPUTERNAME,
    [switch]$Start,
    [switch]$Passthru
    )
    if ($Computername -eq $env:computername) {
    FREE VM Backup More Info & Download 8
    #validate parameters here
    if (-Not (Test-Path $Path)) {
     Write-Warning “Failed to verify VM path $path”
     #bail out
     Return
    }
    if (-Not (Test-Path $VHDRoot)) {
     Write-Warning “Failed to verify VHDRoot $VHDRoot”
     #bail out
     Return
    }
    if ($ISO -AND (-Not (Test-Path $ISO))) {
     Write-Warning “Failed to verify ISO path $ISO”
     #bail out
     Return
    }
    if (-Not (Get-VMSwitch -Name $VMSwitch -ErrorAction SilentlyContinue)) {
     Write-warning “Failed to find VM Switch $VMSwitch on $computername”
     Return
    }
    Write-Verbose “Running locally on $Computername”
    #path for the new VHDX file. All machines will use the same path.
    $VHDPath= Join-Path $VHDRoot “$($name)_C.vhdx”
    Write-Verbose “Creating new $VMType virtual machine”
    #define parameter values based on VM Type
    Switch ($VMType) {
     “Small” {
     Write-Verbose “Setting Small values”
     $MemoryStartup=512MB
     $VHDSize=10GB
     $ProcCount=1
     $MemoryMinimum=512MB
     $MemoryMaximum=1GB
     Break
     }
     “Medium” {
     Write-Verbose “Setting Medium values”
     $MemoryStartup=512MB
     $VHDSize=20GB
     $ProcCount=2
     $MemoryMinimum=512MB
     $MemoryMaximum=2GB
     Break
     }
     “Large” {
     Write-Verbose “Setting Large values”
     $MemoryStartup=1GB
     $VHDSize=40GB
     $ProcCount=4
     $MemoryMinimum=512MB
     $MemoryMaximum=4GB
     Break
     }
     Default {
    FREE VM Backup More Info & Download 9
     Write-Verbose “why are you here?”
     }
    } #end switch
    Write-Verbose “Mem: $MemoryStartup”
    Write-verbose “VHD: $VHDSize”
    Write-Verbose “Proc: $ProcCount”
    #define a hash table of parameters for New-VM
    $newParam = @{
     Name=$Name
     SwitchName=$VMSwitch
     MemoryStartupBytes=$MemoryStartup
     Path=$Path
     NewVHDPath=$VHDPath
     NewVHDSizeBytes=$VHDSize
     ErrorAction=”Stop”
    }
    #define a hash table of parameters for Set-VM
    $setParam = @{
     ProcessorCount=$ProcCount
     DynamicMemory=$True
     MemoryMinimumBytes=$MemoryMinimum
     MemoryMaximumBytes=$MemoryMaximum
     ErrorAction=”Stop”
    }
    if ( $PSBoundParameters.ContainsKey(“Passthru”)) {
     Write-Verbose “Adding Passthru to Set parameters”
     $setParam.Add(“Passthru”,$True)
     Write-Verbose ($setParam | out-string)
    }
    Try {
     Write-Verbose “Creating new virtual machine $name”
     Write-Verbose ($newParam | out-string)
     $VM = New-VM @newparam
    }
    Catch {
     Write-Warning “Failed to create virtual machine $Name”
     Write-Warning $_.Exception.Message
     #bail out
     Return
    }
    if ($VM) {
     If ($ISO) {
     #mount the ISO file
     Try {
     Write-Verbose “Mounting DVD $iso”
     Set-VMDvdDrive -vmname $vm.name -Path $iso -ErrorAction Stop
     }
     Catch {
     Write-Warning “Failed to mount ISO for $Name”
     Write-Warning $_.Exception.Message
     #don’t bail out but continue to try and configure virtual machine
     }
     } #if iso
    FREE VM Backup More Info & Download 10
     Try {
     Write-Verbose “Configuring new virtual machine $name”
     Write-Verbose ($setParam | out-string)
     $VM | Set-VM @setparam
     }
     Catch {
     Write-Warning “Failed to configure virtual machine $Name”
     Write-Warning $_.Exception.Message
     #bail out
     Return
     }
     If ($Start) {
     Write-Verbose “Starting the virtual machine”
     Start-VM -VM $VM
     }
    } #if $VM
    } #if local
    else {
     Write-Verbose “Running Remotely”
     #create a PSSession
     Try {
     $sess = New-PSSession -ComputerName $Computername -ErrorAction Stop
     Write-Verbose “copy the function to the remote session”
     $thisFunction = ${function:New-VMFromTemplate}
     Invoke-Command -ScriptBlock {
     Param($content)
     New-Item -Path Function:New-VMFromTemplate -Value $using:thisfunction -Force |
     Out-Null
     } -Session $sess -ArgumentList $thisFunction
    
     Write-Verbose “invoke the function with these parameters”
     Write-Verbose ($PSBoundParameters | Out-String)
    
     Invoke-Command -ScriptBlock {
     Param([hashtable]$Params)
     New-VMFromTemplate @params
     } -session $sess -ArgumentList $PSBoundParameters
     } #Try
     Catch {
     Write-Warning “Failed to create a remote PSSession to $computername. $($_.Exception.
    message)”
     }
     #remove the PSSession
     Write-Verbose “Removing pssession”
     $sess | Remove-PSSession -WhatIf:$False
    }
    Write-Verbose “Ending command”
    } #end function
    	 

Create a "small" virtual machine on a remote server automatically mounted the Windows Server 2012 ISO file that is on the remote Hyper-V server. After creation the vm starts automatically started.

	PS C:\> New-VMFromTemplate -Name Web03 -VMType Small -ISO d:\iso\windows_server_2012_r2_x64.iso -computername chi-hvr2 -verbose -start

### Using an ISO File

**Note:** you need to know the name of the Windows edition on the ISO file.

**Uitleg bij script**

	.Description This command will list the available Windows images from an ISO file. 
	
	.Example PS C:\> Get-ImageFromISO G:\iso\en_windows_server_2012_x64_dvd_915478.iso
	
    ISOPath : G:\iso\en_windows_server_2012_x64_dvd_915478.iso 
	Name: Windows Server 2012 SERVERSTANDARDCORE 
	Description : Windows Server 2012 SERVERSTANDARDCORE 
	Index   : 1 
	SizeMB  : 6862
	
    ISOPath : G:\iso\en_windows_server_2012_x64_dvd_915478.iso 
	Name: Windows Server 2012 SERVERSTANDARD 
	Description : Windows Server 2012 SERVERSTANDARD 
	Index   : 2 
	SizeMB  : 11444
	
    ISOPath : G:\iso\en_windows_server_2012_x64_dvd_915478.iso 
	Name: Windows Server 2012 SERVERDATACENTERCORE 
	Description : Windows Server 2012 SERVERDATACENTERCORE 
	Index   : 3 
	SizeMB  : 6844
	
    ISOPath : G:\iso\en_windows_server_2012_x64_dvd_915478.iso Name: Windows Server 2012 SERVERDATACENTER 
	Description : Windows Server 2012 SERVERDATACENTER 
	Index   : 4 
	SizeMB  : 11440

    Generally, the only part of the image name you need is what is in upper case. 
	

**Script**

    [cmdletbinding()] 
	Param( 
	[Parameter(Position=0,Mandatory,HelpMessage=”Enter the path to the ISO file.”, ValueFromPipeline,ValueFromPipelineByPropertyName)] [ValidateScript({ Test-Path -path $_})] 
	[Alias(“FullName”)] [string]$Path 
	)

    Process { 
	Write-Verbose “Mounting $path as read-only”

    $iso = Mount-DiskImage -ImagePath $path -Access ReadOnly -PassThru -StorageType ISO
	
    $drive = “{0}:\” -f ($iso | Get-DiskImage | Get-Volume).DriveLetter
	
    $wimPath = Join-Path -Path $drive -ChildPath “sources\install.wim”
	
    Write-Verbose “Reading image information from $wimPath”  #add the ISO path to the output and make sure to sort by index. #The image size is also formatted in MB.
	Get-WindowsImage -ImagePath $wimPath | 
	Add-Member -MemberType NoteProperty -Name ISOPath -Value $path -PassThru | 
	Select ISOPath,@{Name=”Name”;Expression={$_.ImageName}}, @{Name=”Description”;Expression={$_.ImageDescription}}, @{Name=”Index”;Expression={$_.ImageIndex}}, @{Name=”SizeMB”;Expression={$_.ImageSize /1MB -as [int]}} | Sort Index
	
    Write-Verbose “Dismounting disk image”
	
    $iso | Dismount-DiskImage
	
    } #end process
	
    } #end function


For the next script you need to download a Script: Convert-WindowsImage.ps1, you can find it in the GitHub repository -> Opdracht 1 -> Scripts Hyper-V. 
Save it on C:Scripts/ 
The next script will call it. 

**Uitleg bij script**

    
	.Description 
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
	PS C:\> $iso = “G:\iso\en_windows_server_2008_r2_standard_enterprise_datacenter_and_web_ x64_dvd_x15-59754.iso” 
	PS C:\> $newParams=@{ 
		Name = ‘2008Web’ 
		DiskName = ‘WebDemo-01.vhdx’ 
		ISOPath = $Iso Edition = “ServerWeb” 
		Size = 10GB 
		Memory = 1GB 
		Switch = “Work Network” ProcessorCount = 2 
	} 
	PS C:\> c:\scripts\new-vmfromiso.ps1 @newparams
    
	This example creates a hashtable of parameters to splat to the script which will create a new virtual machine running the Web edition of Windows Server 2008. 
	.Example 
	PS C:\> c:\scripts\new-vmfromiso.ps1 -name “DemoVM” -ShowUI
	
    This command will launch the script and create a virtual machine called DemoVM using all 
    15FREE VM Backup  More Info & Download
    of the default settings. The convert GUI will displayed.
	
    .Example 
	PS C:\> invoke-command {c:\scripts\new-vmfromiso.ps1 -name Dev01 -diskname Dev01_C.vhdx -isopath f:\iso\windows2012-x64.iso -edition serverstandardcore -verbose} -comp SERVER01
	
    This command will remotely run this script on SERVER01 to create the desired virtual machine. This script and the Microsoft script have to reside on the remote server. 


**Script**
	
    [cmdletbinding(DefaultParameterSetName=”Manual”,SupportsShouldProcess)]
	
    Param( [Parameter (Position = 0,Mandatory, HelpMessage = “Enter the name of the new virtual machine”)] [ValidateNotNullorEmpty()] [string]$Name,
    [ValidateNotNullorEmpty()] [string]$Path = (Get-VMHost).VirtualMachinePath,
    [Parameter(ParameterSetName=”Manual”,Mandatory,HelpMessage=”Enter the path to the ISO file”)] [ValidateScript({Test-Path $_ })] [string]$ISOPath,
    [Parameter(ParameterSetName=”Manual”,Mandatory,HelpMessage=”Enter the name of the install edition, e.g. Windows Server 2012 R2 SERVERSTANDARD”)] [ValidateNotNullorEmpty()] [string]$Edition,
    [Parameter(ParameterSetName=”Manual”,Mandatory,HelpMessage=”Enter the file name of the new VHD or VHDX file including the extension.”)] [ValidateNotNullorEmpty()] [string]$DiskName,
    [Parameter(ParameterSetName=”Manual”,HelpMessage=”Enter the directory name of the new VHD file.”)] [ValidateNotNullorEmpty()] [string]$DiskPath=(Get-VMHost).VirtualHardDiskPath,
    [Parameter(ParameterSetName=”Manual”)] [ValidateScript({$_ -ge 10GB})]
    16FREE VM Backup  More Info & Download
    [int64]$Size = 20GB,
    [Parameter(ParameterSetName=”Manual”)] [ValidateScript({Test-Path $_ })] [string]$Unattend,
    [ValidateScript({$_ -ge 256MB})] [int64]$Memory = 1GB,
    [ValidateNotNullorEmpty()] #set your default switch [string]$Switch = “Work Network”,
    [ValidateScript({$_ -ge 1})] [int]$ProcessorCount = 2,
    [Parameter(ParameterSetName=”UI”)] [switch]$ShowUI ) #!!! DEFINE THE PATH TO THE CONVERT-WINDOWSIMAGE.PS1 SCRIPT !!! $convert = “c:\scripts\Convert-WindowsImage.ps1”
    if (-Not (Test-Path -Path $convert)) {  Write-Warning “Failed to find $convert which is required.”  Write-Warning “Please download from:”  Write-Warning “ http://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps10fe23a8f”  Write-Warning “and try again.”  #bail out  Return }
    #region creating the VHD or VHDX file if ($pscmdlet.ParameterSetName -eq ‘UI’) {
    if ($pscmdlet.ShouldProcess(“ShowUI”)) {  &$convert -showUIWrite-Warning “You may need to manually use Dismount-DiskImage to remove the mounted ISO file.”  $ok= $False  do {  [string]$vhdPath = Read-Host “`nWhat is the complete name and path of the virtual disk you just created? Press enter without anything to abort”
      if ($vhdPath -notmatch “\w+”) {Write-warning “No path specified. Exiting.”Return  }if (Test-Path -Path $vhdPath) {$ok = $True  }  else {
    17FREE VM Backup  More Info & Download
    Write-Host “Failed to verify that path. Please try again.” -ForegroundColor Yellow  }
      } Until ($ok)  } #should process } else { #manually create the VHD #region Convert ISO to VHD Write-Verbose “Converting ISO to VHD(X)”
    $vhdPath = Join-path -Path $DiskPath -ChildPath $DiskName
    #parse the format from the VHDPath parameter value [regex]$rx = “\.VHD$|\.VHDX$” #regex pattern is case-sensitive if ($vhdpath.ToUpper() -match $rx) {#get the match and strip off the period$Format = $rx.Match($vhdpath.toUpper()).Value.Replace(“.”,””) } else {Throw “The extension for VHDPath is invalid. It must be .VHD or .VHDX”#Bail outReturn }
    #define a hashtable of parameters and values for the Convert-WindowsImage
    $convertParams = @{ SourcePath = $ISOPath SizeBytes = $size Edition = $Edition VHDFormat = $Format VHDPath = $VHDPath ErrorAction = ‘Stop’ }
    if ($Unattend) { $convertParams.Add(“UnattendPath”,$Unattend) } Write-Verbose ($convertParams | Out-String)
    #define a variable with information to be displayed in WhatIf messages $Should = “VM $Name from $ISOPath to $VHDPath”
    #region -Whatif processing If ($pscmdlet.ShouldProcess($Should)) {Try {#call the convert script splatting the parameter hashtable&$convert @convertParams}Catch {Write-Warning “Failed to convert $ISOPath to $VHDPath”
    18FREE VM Backup  More Info & Download
    Write-Warning $_.Exception.Message } } #should process #endregion
    #endregion } #endregion
    #region Creating the virtual machine Write-Verbose “Creating virtual machine $Name” Write-Verbose “VHDPath = $VHDPath” Write-Verbose “MemoryStartup = $Memory” Write-Verbose “Switch = $Switch” Write-Verbose “ProcessorCount = $ProcessorCount” Write-Verbose “Path = $Path”
    #new vm parameters $newParam = @{ Path = $Path Name = $Name VHDPath = $VHDPath MemoryStartupBytes = $Memory SwitchName = $Switch } New-VM @NewParam | Set-VM -DynamicMemory -ProcessorCount $ProcessorCount -Passthru
    #dismount the disk image if still mounted if ($ISOPath -AND  (Get-DiskImage -ImagePath $ISOPath).Attached) { Write-Verbose “dismounting $isopath” Dismount-DiskImage -ImagePath $ISOPath } Write-Verbose “New VM from ISO complete”
    #endregion


If the script you needed to use for ths script is located somewhere else you need to change:
	
	$convert = “c:\scripts\Convert-WindowsImage.ps1”

If you want to use the script: 
Example: 
		
	PS C:\> c:\scripts\new-vmfromiso.ps1 -name Dev01 -diskname Dev01_C.vhdx -isopath f:\iso\ windows2012-x64.iso -edition serverstandardcore –processor 4 –memory 4GB –DiskPath D:\ DevDisks 

Alternative: 
The script you needed to download has a build in UI. 

	PS C:\>C:\scripts\New-VMfromISO.ps1 -Name Test01 -ShowUI

This script doesn't have a provision to connect to a remote server. But if you copy the script to the remote server, you can invoke it with PowerShell remoting from a client.

	PS C:\> invoke-command {c:\scripts\new-vmfromiso.ps1 -name Dev02 -diskname Dev02_C.vhdx -isopath d:\iso\windows2012-x64.iso -edition serverstandardcore –memory 4GB} -computername chi-hvr2

### Virtual Machine Inventory 

With PowerShell you can display information about virtual machines or the Hyper-V host. 

Virtual Machines: 

	PS C:\> get-vm -ComputerName chi-hvr2 

ComputerName = name of a Hyper-V host.

The command above doesn't have any filtering parameters. 

To see only running virtual machines: 

	PS C:\> get-vm -ComputerName chi-hvr2 | where { $_.state -eq “running”}

**Function Get -MyVM**

Descrition: 

This command is a proxy function for Get-VM. The parameters are identical to that command with the addition of a parameter to filter virtual machines by their state. The default is to only show running virtual machines. Use * to see all virtual machines.

Examples: 

PS C:\> get-myvm -computername chi-hvr2

PS C:\scripts> get-myvm -State saved -computername chi-hvr2


    Function Get-MyVM {
    [CmdletBinding(DefaultParameterSetName=’Name’)] 
	param(
		[Parameter(ParameterSetName=’Id’, Position=0, ValueFromPipeline=$true, ValueFromPip elineByPropertyName=$true)]
		[ValidateNotNull()]
		[System.Nullable[guid]]$Id,
    
	[Parameter(ParameterSetName=’Name’, Position=0, ValueFromPipeline=$true)]
	[Alias(‘VMName’)]
	[ValidateNotNullOrEmpty()][string[]]$Name=”*”,
	
    [Parameter(ParameterSetName=’ClusterObject’, Mandatory=$true, Position=0, ValueFromPipeline=$true)]
	[ValidateNotNullOrEmpty()][PSTypeName(‘Microsoft.FailoverClusters.PowerShell.ClusterObject’)][psobject]$ClusterObject,
    
	[Parameter(ParameterSetName=’Id’)]
	[Parameter(ParameterSetName=’Name’)]
	[ValidateNotNullOrEmpty()]
	[string[]]$ComputerName = $env:computername,
	
	[Microsoft.HyperV.PowerShell.VMState]$State=”Running”)

	begin 
	{
	Write-Verbose “Getting virtual machines on $($computername.ToUpper()) with a state of $state”
		try {
			$outBuffer = $null
			if($PSBoundParameters.TryGetValue(‘OutBuffer’, [ref]$outBuffer))
			{
				$PSBoundParameters[‘OutBuffer’] = 1
			}
				$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(‘Get-VM’, [System. Management.Automation.CommandTypes]::Cmdlet)
				#remove my custom parameter because Get-VM won’t recognize it.
				$PSBoundParameters.Remove(‘State’) | Out-Null

    	$scriptCmd = {& $wrappedCmd @PSBoundParameters | Where {$_.state -like “$state”} }$steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)$steppablePipeline.Begin($PSCmdlet)
		} catch {    
    		throw
			} 
		}
		process 
		{
			try{
				$steppablePipeline.Process($_) 
			} catch {throw} 
		} 
		end 
		{
		try {
			$steppablePipeline.End()
		} catch {throw} 
		}
	} #end function 

###Get-Newest Virtual Machines

	get-vm -computer chi-hvr2 | where {$_.CreationTime -ge (Get-Date).AddDays(-7)}

### Hard Disk Report

keep track of virtual disks of each virtual machine. 

	get-vm web01 -computername chi-hvr2 | select -expand harddrives | get-vhd -computerName chi-hvr2

Here there can be an error, then you need to use the following function.

**Function Get-VHDInfo**

Description: 

This command will get virtual disk information for a given set of virtual machines on a Hyper-V server. The default is all virtual machines.
The command uses PowerShell remoting to verify that the virtual disk file exists.

	Function Get-VHDInfo{
	[cmdletbinding()] 
	Param(
	[Parameter(Position=0)]
	[ValidateNotNullorEmpty()]
	[alias(“Name”)]
	[string[]]$VMName=”*”,	
	[ValidateNotNullorEmpty()]
	[string]$Computername = $env:computername
	)
	Write-Host “Getting disk file information on $computername for virtual machines $VMName” -ForegroundColor Cyan

	Try{
	$disks = Get-VM -name $VMname -computername $computername -ErrorAction Stop | Select-Object -ExpandProperty harddrives | Select-Object VMName,Path,Computername 
	}
	catch {
		Throw $_
	}
	#continue if there are some disks
	if ($disks) {
	
	 #create a temporary PSSession to the remote computer so we can test the path 
	Try {
		
		if ($computername -ne $env:computername) {
			
		Write-Verbose “Creating a temporary PSSession top $computername”          $sess = New-Pssession -ComputerName $Computername -ErrorAction Stop
		}
	}
	catch {
		#failed to create PSSession
		Throw $_
		#bail out
		Return
	}
	Write-Verbose “Processing disks...”
	foreach ($disk in $disks) {

	Write-Verbose (“VM {0} : {1}” -f $disk.VMName,$disk.path)

	Try {
		 $disk | Get-VHD -ComputerName $computername -ErrorAction Stop |         Select-Object -property @{Name=”VM”;Expression={$disk.vmname}},        Path,VHDFormat,VHDType,Size,FileSize,FragmentationPercentage,ParentPath,Attached,        @{Name=”Verified”;Expression={
		if ($computername -eq $env:computername) {
			Test-Path -path $_.path
		}
		else {
			$diskpath = $_.path
			Invoke-command -ScriptBlock {Test-Path -path $using:diskpath} -session $sess
		}
		}},Computername
	} #Try
	Catch {
		 write-warning “Failed to find $($disk.path)”
	     #write a mostly empty custom object for the missing file 
		$hash=[ordered]@{   
	     	VM = $disk.VMName
         	Path = $disk.path         
			VHDFormat = (split-path $disk.path -Leaf).split(“.”)[1].ToUpper()
	        VHDType = “UNKNOWN”         
			Size = 0         
			FileSize = 0         
			FragmentationPercentage=$null         
			ParentPath=$null         
			Attached=$False         
			Verified=$False         
			Computername =$disk.Computername     
		    }         
			[pscustomobject]$hash     
		} #catch
	    } 	#foreach disk 
	}
	#clean up if ($sess){
	 Write-Verbose “Removing PSSession”    
	 Remove-PSSession $sess 
	} 
	} #end function

Use it like this: 
	
	get-vhdinfo chi* -Computername chi-hvr2 | out-gridview -title "chicago VMs"

Find virtual machines with missing files. 

	get	-vhdinfo -computername win81-ent-01 | where {-Not $_.Verified}

Total file size in GB for all virtual disks: 

	get-vhdinfo -computername chi-hvr2  | measure Filesize -sum | Format-Table Count,@{Name=”SizeGB”;Expression={$_.Sum/1gb}} –AutoSize

### Memory Usage 

The Hyper-V module includes a cmdlet that will display memory information

	Get-VMMemory -VMName CHI-FP02 -ComputerName chi-hvr2 | select * 

(select * isn't nessacary)

the following function provides a more meaningful report. 

Description: 

This command gets memory settings for a given Hyper-V virtual machine. All memory values are in MB. The command requires the Hyper-V module

Parameter VMName: 

The name of the virtual machine or a Hyper-V virtual machine object. This parameter has an alias of “Name.” 

.Parameter VM:

A Hyper-V virtual machine object.

.Parameter Computername:

The name of the Hyper-V server to query. The default is the local host.

    Function Get-VMMemoryReport {
    
    [cmdletbinding(DefaultParameterSetName=”Name”)]
     Param( 
	[Parameter(Position=0,HelpMessage=”Enter the name of a virtual machine”, ValueFromPipeline,ValueFromPipelineByPropertyName, ParameterSetName=”Name”)] 
	[alias(“Name”)] 
	[ValidateNotNullorEmpty()] 
	[string]$VMName=”*”,
	[Parameter(Position=0,Mandatory,HelpMessage=”Enter the name of a virtual machine”, ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName=”VM”)]
	[ValidateNotNullorEmpty()] 
	[Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM, 
	[ValidateNotNullorEmpty()] 
	[Parameter(ValueFromPipelinebyPropertyName)] 
	[ValidateNotNullorEmpty()] 
	[string]$Computername=$env:COMPUTERNAME
	)
	Begin {
		Write-Verbose "Starting $($MyInvocation.Mycommand)"
	} #begin

	Process {

		if($PSCmdlet.ParameterSetName -eq "Name") {
			Try {
				$VMs = Get-VM -name $VMName -ComputerName $computername -ErrorAction Stop
			}
			Catch {
				Write-Warning "Failed to find VM $Vmname on $computername"
				#bail out
				Return
			}
		}
		else {
			$VMs = $VM
		}
		foreach ($V in $VMs) {
		#get memory values
		Try {
			Write-Verbose "Querying memory for $($v.name) on $($computername.ToUpper())" $memorysettings = Get-VMMemory -VMName $v.name -ComputerName $Computername -ErrorAction Stop

		if ($MemorySettings) {
		#all values are in MB
		$hash = [ordered]@{
			Computername = $v.ComputerName.ToUpper()
			Name = $V.Name
			Dynamic = $V.DynamicMemoryEnabled
			Dynamic = $V.DynamicMemoryEnabled
			Assigned = $V.MemoryAssigned/1MB
			Demand = $V.MemoryDemand/1MB 
			Startup = $V.MemoryStartup/1MB 
			Minimum = $V.MemoryMinimum/1MB 
			Maximum = $V.MemoryMaximum/1MB
			Buffer =  $memorysettings.buffer
			Priority = $memorysettings.priority
		}
		#Write the new object to the pipeline
		New-Object -TypeName PSObject -Property $hash
		} #if $memorySettings found
		} # Try
		Catch {
			Throw $_
		} #Catch 
		} #foreach $v in $VMs
	} #process
	End {
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
	} #end
	} #end Get-VMMemoryReport


Use: 

	Get-VMMemoryReport chi-dc04 -Computername chi-hvr2

Another example where it shows everything in a html report: 

	get-vm -computer chi-hvr2 | Where { $_.state -eq “running” }| get-vmmemoryreport | Sort Maximum | convertto-html -title “VM Memory Report” -css c:\scripts\blue. css -PreContent “<H2>Hyper-V Memory Report</H2>” -PostContent “<i>report created by $env:username</i>” | out-file c:\work\vmmemreport.htm


### Get VM Last Use

Function Get-VMLastUse

Description: 

This command will write a custom object to the pipeline which should indicate when the virtual machine was last used. The command finds all hard drives that are associated with a Hyper-V virtual machine and selects the first one. 
The assumption is that if the virtual machine is running the hard drive file will be changed. The function retrieves the last write time property from the first VHD or VHDX file.
You can pipe a collection of Hyper-V virtual machines or specify a virtual machine name. Wildcards are supported. The default is to display last use data for all virtual machines. This command must be run on the Hyper-V server in order to get file system information from the disk file. Therefore, it uses PowerShell remoting to query remote servers.
    
    Function Get-VMLastUse {
    [cmdletbinding()] Param ( [Parameter(Position=0, HelpMessage=”Enter a Hyper-V virtual machine name”, ValueFromPipeline,ValueFromPipelinebyPropertyName)] [ValidateNotNullorEmpty()] [alias(“vm”)] [object]$Name=”*”, [Parameter(ValueFromPipelineByPropertyname)] [ValidateNotNullorEmpty()] [string]$Computername=$env:COMPUTERNAME )
    Begin {Write-Verbose -Message “Starting $($MyInvocation.Mycommand)”  } #begin
    Process {if ($name -is [string]) {Write-Verbose -Message “Getting virtual machine(s)”Try {$vms = Get-VM -Name $name -ComputerName $computername -ErrorAction Stop}Catch {Write-Warning “Failed to find a VM or VMs with a name like $name on $($computername.ToUpper())”#bail outReturn}}else {#otherwise we’ll assume $Name is a virtual machine objectWrite-Verbose “Found one or more virtual machines matching the name”$vms = $name}if ($vms) { 
     if ($vms[0].ComputerName -ne $env:computername) {#create a temporary PSSessionTry {Write-Verbose “Creating a temporary session to $($vms[0].ComputerName)”New-PSSession -ComputerName $vms[0].ComputerName -Name $vms[0]. ComputerName -ErrorAction Stop | Out-Null}Catch {Write-warning “Failed to create a PSSession to $($vms[0].ComputerName)”Throw $_#bail outReturn}}foreach ($vm in $vms) {Write-Verbose “Processing $($vm.name)”if ($vm.harddrives) {$sb = {Param($v)  #get first drive fileTry {  $diskFile = Get-Item -Path $v.path  -ErrorAction Stop  Write-Verbose “..found $($diskFile.fullname)”  $diskfile | Select-Object -property @{Name=”VMName”;Expression={$v. vmname}},  @{Name=”LastUse”;Expression={$DiskFile.LastWriteTime}},  @{Name=”LastUseAge”;Expression={(Get-Date) - $diskFile.LastWriteTime}},  @{Name=”Computername”;Expression={$v.computername}}  }  Catch {Write-Warning “Failed to find $($v.Path) for $($v.vmname) on $($v. computername)”  } } #scriptblock
     if ($vm.computername -eq $env:computername) {Invoke-Command -ScriptBlock $sb -ArgumentList $vm.HardDrives[0] } else {Invoke-Command -ScriptBlock $sb -ArgumentList $vm.HardDrives[0] -HideComputerName -session (Get-PSSession -Name $vm.computername) |Select VMName,LastUse,LastUseAge,Computername } } #if VM has hard drive files else { Write-Warning “Failed to find any hard drive files for $($vm.vmname) on $($vm. computername)”   }}#foreach} #if $vmselse {#this should never happenWrite-Warning “No virtual machines.”
     }#clean up any PSSessionsRemove-PSSession -Name $vm.computername -ErrorAction SilentlyContinue } #process
    End {Write-Verbose -Message “Ending $($MyInvocation.Mycommand)” } #end
    } #end function 

use it like: 
	get-vmlastuse -computer chi-hvr2

or with pipes: 
	
	 get-vm chi* -computer chi-hvr2 | where {$_.state -eq ‘off’} | get-vmlastuse | sort LastUseAge -descending

Remove very old machines: 

	 get-vmlastuse chi* -computer chi-hvr2 | where {$_.lastuseage.totalDays -gt 75} | Select -expand vmname | remove-vm -ComputerName chi-hvr2 -whatif

### Get VM Operating System

Function Get-VMOS

Description: 

This command will display the installed Windows operating system on a Hyper-V virtual machine. The virtual machine must be running.

The function uses WMI to query remote computers. 

	Function Get-VMOS {
	[cmdletbinding()] 
	Param( 
	[Parameter(Position=0,HelpMessage=”Enter the name of a virtual machine”, ValueFromPipeline,ValueFromPipelinebyPropertyName)] 
	[ValidateNotNullorEmpty()] 
	[Alias(“Name”)] 
	[string]$VMName=”*”, 
	[Parameter(ValueFromPipelinebyPropertyName)] 
	[string]$Computername=$env:COMPUTERNAME 
	)

	Begin {
		Write-Verbose “Starting $($MyInvocation.Mycommand)” 
	} #begin

	Process {
	Write-Verbose “Querying virtual machines on $($Computername.ToUpper())”

	$wmiParam=@{
	Namespace= “root/virtualization/v2” 
	ClassName= “Msvm_VirtualSystemManagementService” 
	ComputerName= $Computername 
	errorAction= “Stop” 
	errorVariable= “myErr” 
	}

	Try {
		$vsm = Get-WmiObject @wmiparam
	}
	Catch {
	 	$myerr.errorrecord.exception.message
	}
	
	#modify the parameter hash 
	$wmiParam.ClassName= “MSVM_Computersystem” 
	if ($VMName -eq “*”) {
		$filter = “Caption=’Virtual Machine’”
	}
	elseif ($VMName -match “\*”) {
		#replace * with %
		$elementname = $VMName.Replace(“*”,”%”)
	    $filter = “elementname LIKE ‘$elementname’” 
	}
	else {
		$filter = "elementname='$VMName'"
	}

	$wmiParam.filter= $filter 
	Write-verbose “Querying virtual machine $VMName” 
	write-Verbose ($wmiParam | Out-String)

	Try {
		$vm = Get-WmiObject @wmiparam
	}
	Catch {
		$myerr.errorrecord.exception.message 
	}
	
	if ($vm) {

	#get virtual system data and filter out checkpoints
	$vsd = $vm.GetRelated(“MSVM_VirtualSystemSettingData”) | where {$_.Description -notmatch “^Checkpoint”}

	#an array of items to get 
	#http://msdn.microsoft.com/en-us/library/hh850062(v=vs.85).aspx 
	[uint32[]]$requested = @(1,106)

	$result = $vsm.GetSummaryInformation($vsd,$requested)

	#display the result
	$result.summaryinformation | 
	select @{Name=”VMName”;Expression={$_.Elementname}}, 
	@{Name=”OperatingSystem”;Expression={$_.GuestOperatingSystem}},
	@{Name=”Computername”;Expression={$vsm.pscomputername}}
	}
	else { 
		  Write-Warning “Failed to find virtual machine $VMName” 
	}
	
	} #process

	End {
		 Write-Verbose -Message “Ending $($MyInvocation.Mycommand)”
	} #end

	} #end function

**Note:**
this function relies on Get-WMIObject --> you must have WMI access to any remote computer.

	get-vmos chi-dc04 -computername chi-hvr2

you also can query multiple machines: 

	get-vmos chi* -computername chi-hvr2

**Note:**

some virtual machines have no OS because they are not running.

### Get Mounted ISO files

	Get-VM -computername chi-hvr2 | select -expand dvddrives | where Path

if you want to select a subset of properties: 

	 Get-VM -computername chi-hvr2 | select -expand dvddrives | where Path | Select Computername,VMName,Path,DVDMediaType | out-gridview -title “Loaded ISO”.


### Identifying Orphaned VHD/VHDX files

Function Get-ObsoluteVHD 

Description: 

This command will search a directory for VHD or VHDX files that are not attached to any existing Hyper-V virtual machines. The default behavior is to search the default virtual hard disk path on the local computer.

	Function Get-ObsoluteVHD {

	[cmdletbinding()]

	Param(
	[Parameter(Position=0)]
	[ValidateNotNullorEmpty()]
	#use the value for -Computername is specified, otherwise the local computer 
	[string]$Path=(Get-VMHost -computername ( &{if ($computername) { $computername} else { $env:computername}})).VirtualHardDiskPath, 
	[Alias(“CN”)] 
	[ValidateNotNullorEmpty()] 
	[string]$Computername=$env:computername 
	)

	Write-Verbose -Message “Starting $($MyInvocation.Mycommand)” 
	Write-Verbose “Searching for obsolete virtual disk files in $Path on $($Computername. ToUpper())”

	#initialize an array to hold file information 
	$files = @()

	Try {
		 #get currently used virtual disk files
		 Get-VM -computername $computername -ErrorAction Stop | Select -ExpandProperty 
	HardDrives |
		 Get-VHD -ComputerName $computername |
		 foreach { 
			$files+=$_.path
	        if ($_.parentPath) {         
			$files+=$_.parentPath 
			} #if path
		} #foreach
	} #Try
	Catch {
		Throw $_
		#bail out
	}

	if ($files) {
		#filter out duplicates
		 $diskfiles = $files | Sort | Get-Unique -AsString

		write-verbose “Attached files”
		$diskfiles | Write-Verbose

		write-verbose “Orphaned files in $path”
		$sb = {
			
		Param($path)     
		if (Test-Path -path $Path) {
		dir -Path $path -file -filter *.vhd? -Recurse
		}
		else {
			Write-Warning “Failed to find path $path on $($env:computername)"
		}
		}
		$found = if ($Computername -ne $env:computername) {
			Invoke-Command -ScriptBlock $sb -ComputerName $computername -HideComputerName -ArgumentList @($path)
		}
		else {
			&$sb $path
		}
		if ($found) {
			Write-Verbose “Found $($found.count) files”        
			$found.fullname | write-verbose         
			$found | where {$files -notcontains $_.fullname}    
		}
		else {
			 Write-Host “No files found in $path on $computername” -ForegroundColor Red    
		}
	} #if files were found
	Write-Verbose -Message “Starting $($MyInvocation.Mycommand)”  
	} #end function 

Example: 

	get-obsolutevhd -computer server01

Shows the unused virtual disk files in the default location. If you want to delete them use: 
	
	$old = get-obsoletevhd -computer server01

Here we save them to a variable then use invoke to delete: 

	invoke-command { $using:old | del -whatif } -computername server01

### Deleting Obsolete Snapshots 

Another task is to clean up old or obsolete snapshots. 

	Get-VMSnapshot -VMName * -ComputerName chi-hvr2 | Select Computername,VMName,Name,Snapsh otType,CreationTime,@{Name=”Age”;Expression={ (Get-Date) - $_.CreationTime }}

If you also want to know how much space they are consuming.

	Invoke-Command { 
	Get-VMSnapshot -VMName * |Select -ExpandProperty HardDrives | Get-Item | 
	Measure-Object -Property Length -sum | 
	Select Count,@{Name=”SizeGB”;Expression={$_.Sum/1GB}} 
	} -ComputerName chi-hvr2 | Select * -ExcludeProperty runspaceId 

If we combine the two: 

	Param( 
	[string[]]$VMName=”*”, 
	[string]$Computername=$env:computername)

	Invoke-Command -scriptblock { 
	Get-VMSnapshot -VMName $using:VMName | 
	Select Computername,VMName,Name,SnapshotType,CreationTime, 
	@{Name=”Age”;Expression={ (Get-Date) - $_.CreationTime }}, 
	@{Name=”SizeGB”; 
	Expression = { ($_.HardDrives | Get-Item | Measure-Object -Property length -sum).sum/1GB }} 
	} -computername $computername -HideComputerName | Select * -ExcludeProperty RunspaceID

In a full-fledged function

Function Remove-OldVMSnapshot:

Description: 

This command will find and remove snapshots older than a given number of days, the default is 90, on a Hyper-V server. You can limit the removal process to specific virtual machines as well as specific types of VM snapshots. 
This command will remove all child snapshots as well so use with caution. The command supports -Whatif and -Confirm. 

	Function Remove-OldVMSnapshot {

	[cmdletbinding(SupportsShouldProcess,ConfirmImpact=”High”,DefaultParameterSetName=”A ll”)]

	Param ( 
	[Parameter(Position=0)] 
	[ValidateNotNullorEmpty()] 
	[string]$VMName=”*”,

	[Parameter(Position=1)] 
	[ValidateScript({$_ -ge 1 })] 
	[Alias(“days”)] 
	[int]$Age=90,

	[Parameter(Position=1,ParameterSetName=”ByType”)] 
	[ValidateNotNullorEmpty()] 
	[Alias(“type”)]
	[Microsoft.HyperV.PowerShell.SnapshotType]$SnapshotType = “Standard”,

	[ValidateNotNullorEmpty()] 
	[Alias(“CN”)] 
	[string]$computername = $env:computername 
	)

	Write-Verbose -Message “Starting $($MyInvocation.Mycommand)” 
	
	#parameters for Get-VMSnapshot 
	$getParams= @{ 
	Computername = $computername 
	ErrorAction = “Stop” 
	VMName = $VMName 
	}

	if ($PSCmdlet.ParameterSetName -eq ‘ByType’) {
		Write-Verbose “Limiting snapshots to type $SnapshotType”
		$getParams.Add(“SnapshotType”,$SnapshotType) 
	}

	Try {
		 [datetime]$Cutoff = ((Get-Date).Date).AddDays(-$Age)
		 Write-Verbose “Searching for snapshots equal to or older than $cutoff on $computername”
		 $snaps = Get-VMSnapshot @getParams | Where {$_.CreationTime -le $Cutoff } 
	}
	Catch {
		Throw $_
	}
	
	if ($snaps) {
		Write-Verbose “Found $($snaps.count) snapshots to be removed”
		$snaps |  Remove-VMSnapshot -IncludeAllChildSnapshots 
	}

	Write-Verbose -Message “Ending $($MyInvocation.Mycommand)”

	} #end function 

Use:

	remove-oldvmsnapshot -days 7 -computername chi-hvr2 -whatif
	What if: Remove-VMSnapshot will remove snapshot “Profile Cleanup Test”.
	What if: Remove-VMSnapshot will remove snapshot “CHI-CORE01 – Check 1”.
	What if: Remove-VMSnapshot will remove snapshot “DCTEST – Check 1”

running without whatif, these snapshots would be removed. 

### Querying Hyper-V Event Logs

Here we are going to keep an eye on logged events.

	 Get-EventLog -LogName system -Source “Microsoft-Windows-Hyper-V*” -newest 100  -ComputerName Chi-HVr2 | Sort Source | Format-Table -GroupBy Source -property TimeGenerated,EntryType,Message -Wrap –AutoSize

if you want to limit your search 

	Get-EventLog -LogName system -Source “Microsoft-Windows-Hyper-V*” -EntryType Error,Warning  -ComputerName Chi-HVr2 -After (Get-Date).AddDays(-3)

Hyper-V has also his own set of operational logs which you can query with Get-WinEvent

	Get-WinEvent -ListLog *Hyper-V*

If you want to query a remote computer, you must configure a firewall exception 

	invoke-command {Get-WinEvent -ListLog *Hyper-V*} -ComputerName chi-hvr2

If you want to limit your search to those logs that have entries.

	invoke-command {Get-WinEvent -ListLog *Hyper-V* | where {$_.recordcount -gt 0} | Select Logname,RecordCount} -ComputerName chi-hvr2

If you know the name of the log to query: 

	invoke-command {Get-WinEvent -ListLog *Hyper-V* | where {$_.recordcount -gt 0} | Select Logname,RecordCount} -ComputerName chi-hvr2

Use a hashtable of filtering options if you need more entries 

	$filterHash = @{
	LogName = “Microsoft-Windows-Hyper-V-Config-Admin”
	Level = 2
	StartTime = (Get-Date).AddDays(-7)
	}
	get-winevent -FilterHashtable $filterhash | format-list 

Function Get -HyperVEvents

Description: 
This command will search a specified server for all Hyper-V related Windows Operational logs and get all errors and warnings that have been recorded in the specified number of days which is 7 by default.
The command uses PowerShell remoting to query event logs and resolve SIDs to account names. The remote event log management firewall exception is not required to use the command.

	Function Get-HyperVEvents {
	[cmdletbinding()]
	
	Param(
	[Parameter(Position=0,HelpMessage=”Enter the name of a Hyper-V host”)] 
	[ValidateNotNullorEmpty()] 
	[Alias(“CN”,”PSComputername”)]
	[string]$Computername=$env:COMPUTERNAME, 
	[ValidateScript({$_ -ge 1})] 
	[int]$Days=7,
	[Alias(“RunAs”)] 
	[System.Management.Automation.Credential()]$Credential = [System.Management.Automation. PSCredential]::Empty 
	)

	Write-Verbose “Starting $($MyInvocation.MyCommand)”
	Write-Verbose “Querying Hyper-V logs on $($computername.ToUpper())”
	
	#define a hash table of parameters to splat to Invoke-Command 
	$icmParams=@{ 
	ErrorAction=”Stop”
	ErrorVariable=”MyErr”
	Computername=$Computername 
	HideComputername=$True 
	}
	
	if ($credential.username) {
		Write-Verbose “Adding a credential for $($credential.username)”
		$icmParams.Add(“Credential”,$credential)
	}

	#define the scriptblock to run remotely and get events using Get-WinEvent 
	$sb = {

	Param([string]$Verbose=”SilentlyContinue”)

	#set verbose preference in the remote scriptblock 
	$VerbosePreference=$Verbose
	
	#calculate the cutoff date 
	$start = (Get-Date).AddDays(-$using:days)
	Write-Verbose “Getting errors since $start”

	#construct a hash table for the -FilterHashTable parameter in Get-WinEvent 
	$filter= @{
	Logname= “Microsoft-Windows-Hyper-V*”
	Level=2,3
	StartTime= $start
	}

	#search logs for errors and warnings 
	#turn off errors to ignore exceptions about no matching records, which would be ok. 
	Try {
		#add a property for each entry that translates the SID into
		#the account name
		Get-WinEvent -filterHashTable $filter -ErrorAction Stop | foreach {
		#add some custom properties
		$_ | Add-Member -MemberType AliasProperty -Name “Type” -Value “LevelDisplayName” 
		
		$_ | Add-Member -MemberType ScriptProperty -Name Username -Value {
		[WMI]$Resolved = “root\cimv2:Win32_SID.SID=’$($this.UserID)’”
			#write the resolved name to the pipeline
			“$($Resolved.ReferencedDomainName)\$($Resolved.Accountname)”
		} -PassThru
		}
	}
	Catch {
		Write-Warning “No matching events found.” 
	}

	} #close scriptblock

	#add the scriptblock to the parameter hashtable for Invoke-Command 
	$icmParams.Add(“Scriptblock”,$sb)

	if ($VerbosePreference -eq “Continue”) {
		#if this command was run with -Verbose, pass that to the scriptblock
		#which will be running remotely.
		Write-Verbose “Adding verbose scriptblock argument”
		$sbArgs=”Continue”
		$icmParams.Add(“Argumentlist”,$sbArgs) 
	}

	Try {
		#invoke the scriptblock remotely and pass properties to the pipeline, except 
		#for the RunspaceID from the temporary remoting session which we don’t need.
	}
	Catch {
		#Invoke-Command failed
		Write-Warning “Failed to connect to $($computername.ToUpper())”
		Write-Warning $MyErr.errorRecord
		#bail out of the function and don’t do anything else 
		Retrun
	}

	#All done here
	Write-Verbose "Ending $($MyInvocation.MyCommand)"

	} #end function

This function gives all errors and warnings recorded in the last 7 days.

Use: 

	get-hypervevents -computername chi-hvr2

Example with username addition:

	get-hypervevents -computername chi-hvr2 -Days 180 | where {$_.username -match “globomantics”} | Select Logname,TimeCreated,Username,Type,Message


### A Hyper-V Health Report

In the folder with script you can find a script that generates a Hyper-V health report. The script is called New-HVHealthReport.ps1

Syntax: 

	<path>\New-HVHealthReport.ps1 [[-Computername] <String>] [-Path <String>] [-RecentCreated <Int32>] [-LastUsed <Int32>] [-Hours <Int32>] [-Performance] [-Metering] [<CommonParameters>]


It includes the full help

Use: 
	
	C:\scripts\New-HVHealthReport.ps1 -Computername chi-hvr2 -path c:\work\hvr2.htm -performance


### Tips and Tricks 

Set default value for ComputerName parameter of Hyper-V cmdlets.

	$hv = “chi-hvr2”
	Get-VM -ComputerName $hv

**Note:** This default value only lasts for as long as your PowerShell session is open, you can add this command to your Powershell profile if you always want this default. 

Instead of modifying virtual machines and other objects using the Set-* cmdlets, first use Get-* command to verify I am selecting the right objects. 

