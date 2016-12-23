#requires -version 3.0

Function New-VMFromTemplate {

<#
.Synopsis
Provision a new Hyper-V virtual machine based on a template
.Description
This script will create a new Hyper-V virtual machine based on a template or hardware profile. You can create a Small, Medium or Large virtual machine. You can specify the virtual switch and paths for the virtual machine and VHDX files.

All virtual machines will be created with dynamic VHDX files and dynamic memory. The virtual machine will mount the specified ISO file so that you can start the virtual machine and load an operating system.

VM Types
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
The name of the Hyper-V server. If you specify a remote server, the command will attempt to make a remote PSSession and use that. Any paths will be relative to the remote computer.
Parameter Start
Start the virtual machine immediately.
.Example
PS C:\> New-VMFromTemplate WEB2012-01 -VMType Small -passthru

Name       State CPUUsage(%) MemoryAssigned(M) Uptime   Status
----       ----- ----------- ----------------- ------   ------
WEB2012-01 Off   0           0                 00:00:00 Operating normally
.Example
PS C:\> New-VMFromTemplate -name DBTest01 -VMType Medium -ISO G:\ISO\Win2k12R2.iso -computername SERVER02 -VHDRoot F:\VHDS -start

This will create a Medium sized virtual machine on SERVER01 called DBTest. The VHDX file will be created in F:\VHDS. The virtual machine will be stored in the default location. An ISO file will also be mounted. After the virtual machine is created, it will be started.
.Notes

Version 2.0
Last Updated June 17, 2014

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.Link
New-VM
Set-VM

#>

[cmdletbinding(SupportsShouldProcess)]

Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the name of your new virtual machine")]
[ValidateNotNullOrEmpty()]
[string]$Name,

[ValidateSet("Small","Medium","Large")]
[string]$VMType="Small",

[ValidateNotNullorEmpty()]
[string]$Path = (Get-VMHost).VirtualMachinePath,

[ValidateNotNullorEmpty()]
[string]$VHDRoot=(Get-VMHost).VirtualHardDiskPath,

[Parameter(HelpMessage="Enter the path to an install ISO file")]
[string]$ISO,

[string]$VMSwitch = "Work Network",

[ValidateNotNullorEmpty()]
[string]$Computername = $env:COMPUTERNAME,
[switch]$Start,
[switch]$Passthru
)

if ($Computername -eq $env:computername) {

#validate parameters here
if (-Not (Test-Path $Path)) {
  Write-Warning "Failed to verify VM path $path"
  #bail out
  Return
}

if (-Not (Test-Path $VHDRoot)) {
  Write-Warning "Failed to verify VHDRoot $VHDRoot"
  #bail out
  Return
}

if ($ISO -AND (-Not (Test-Path $ISO))) {
  Write-Warning "Failed to verify ISO path $ISO"
  #bail out
  Return
}

if (-Not (Get-VMSwitch -Name $VMSwitch -ErrorAction SilentlyContinue)) {
  Write-warning "Failed to find VM Switch $VMSwitch on $computername"
  Return
}

Write-Verbose "Running locally on $Computername"
#path for the new VHDX file. All machines will use the same path.
$VHDPath= Join-Path $VHDRoot "$($name)_C.vhdx"

Write-Verbose "Creating new $VMType virtual machine"

#define parameter values based on VM Type
Switch ($VMType) {
    "Small" {
        Write-Verbose "Setting Small values"
        $MemoryStartup=512MB
        $VHDSize=10GB
        $ProcCount=1
        $MemoryMinimum=512MB
        $MemoryMaximum=1GB
        Break
    }
    "Medium" {
        Write-Verbose "Setting Medium values"
        $MemoryStartup=512MB
        $VHDSize=20GB
        $ProcCount=2
        $MemoryMinimum=512MB
        $MemoryMaximum=2GB
        Break
    }
    "Large" {
        Write-Verbose "Setting Large values"
        $MemoryStartup=1GB
        $VHDSize=40GB
        $ProcCount=4
        $MemoryMinimum=512MB
        $MemoryMaximum=4GB
        Break
    }
    Default {
        Write-Verbose "why are you here?"
    }
    
} #end switch

Write-Verbose "Mem: $MemoryStartup"
Write-verbose "VHD: $VHDSize"
Write-Verbose "Proc: $ProcCount"

#define a hash table of parameters for New-VM
$newParam = @{
 Name=$Name
 SwitchName=$VMSwitch
 MemoryStartupBytes=$MemoryStartup
 Path=$Path
 NewVHDPath=$VHDPath
 NewVHDSizeBytes=$VHDSize
 ErrorAction="Stop"
}

#define a hash table of parameters for Set-VM
$setParam = @{
 ProcessorCount=$ProcCount
 DynamicMemory=$True
 MemoryMinimumBytes=$MemoryMinimum
 MemoryMaximumBytes=$MemoryMaximum
 ErrorAction="Stop"
}

if ( $PSBoundParameters.ContainsKey("Passthru")) {
    Write-Verbose "Adding Passthru to Set parameters"
    $setParam.Add("Passthru",$True)
    Write-Verbose ($setParam | out-string)
}
Try {
    Write-Verbose "Creating new virtual machine $name"
    Write-Verbose ($newParam | out-string)
    $VM = New-VM @newparam
}
Catch {
    Write-Warning "Failed to create virtual machine $Name"
    Write-Warning $_.Exception.Message
    #bail out
    Return
}

if ($VM) {
   If ($ISO) {
    #mount the ISO file
    Try {
        Write-Verbose "Mounting DVD $iso"
        Set-VMDvdDrive -vmname  $vm.name -Path $iso -ErrorAction Stop
    }
    Catch {
        Write-Warning "Failed to mount ISO for $Name"
        Write-Warning $_.Exception.Message
        #don't bail out but continue to try and configure virtual machine
    }
   } #if iso

   Try {
        Write-Verbose "Configuring new virtual machine $name"
        Write-Verbose ($setParam | out-string)
        $VM | Set-VM @setparam
    }
    Catch {
        Write-Warning "Failed to configure virtual machine $Name"
        Write-Warning $_.Exception.Message
        #bail out
        Return
    }
    If ($Start) {
        Write-Verbose "Starting the virtual machine"
        Start-VM -VM $VM
    }

} #if $VM
} #if local
else {
    Write-Verbose "Running Remotely"

    #create a PSSession
    Try {
    $sess = New-PSSession -ComputerName $Computername -ErrorAction Stop

    Write-Verbose "copy the function to the remote session"
    $thisFunction = ${function:New-VMFromTemplate}
    Invoke-Command -ScriptBlock {
    Param($content) 
    New-Item -Path  Function:New-VMFromTemplate -Value $using:thisfunction -Force |
    Out-Null
    } -Session $sess -ArgumentList $thisFunction
    
    Write-Verbose "invoke the function with these parameters"
    Write-Verbose ($PSBoundParameters | Out-String)
    
    Invoke-Command -ScriptBlock { 
     Param([hashtable]$Params) 
     New-VMFromTemplate @params
     } -session $sess -ArgumentList $PSBoundParameters

    } #Try
    Catch {
        Write-Warning "Failed to create a remote PSSession to $computername. $($_.Exception.message)"
    }

    #remove the PSSession
    Write-Verbose "Removing pssession"
    $sess | Remove-PSSession -WhatIf:$False
}

Write-Verbose "Ending command"

} #end function
