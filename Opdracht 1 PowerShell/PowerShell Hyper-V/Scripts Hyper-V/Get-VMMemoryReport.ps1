#requires -version 3.0
#requires -module Hyper-V

Function Get-VMMemoryReport {
<#
.Synopsis
Get a VM memory report
.Description
This command gets memory settings for a given Hyper-V virtual machine. All memory values are in MB. The command requires the Hyper-V module.
.Parameter VMName
The name of the virtual machine or a Hyper-V virtual machine object. This parameter has an alias of "Name." 
.Parameter VM
A Hyper-V virtual machine object. See examples.
.Parameter Computername
The name of the Hyper-V server to query. The default is the local host.
.Example
PS C:\> Get-VMMemoryReport chi-dc04 -ComputerName chi-hvr2 

Computername : CHI-HVR2
Name         : CHI-DC04
Dynamic      : True
Assigned     : 1024
Demand       : 849
Startup      : 1024
Minimum      : 1024
Maximum      : 2048
Buffer       : 20
Priority     : 50


Get a memory report for a single virtual machine.
.Example
PS C:\> Get-VM -computer chi-hvr2 | where {$_.state -eq 'running'} | Get-VMMemoryReport | format-table -autosize

Computername Name       Dynamic Assigned Demand Startup Minimum Maximum Buffer Priority
------------ ----       ------- -------- ------ ------- ------- ------- ------ --------
CHI-HVR2     CHI-CORE01    True      512    332     512     512    1024     20       50
CHI-HVR2     CHI-DC04      True     1024    849    1024    1024    2048     20       50
CHI-HVR2     CHI-FP02      True      512    389     512     512    2048     20       50
CHI-HVR2     CHI-Win81     True     1216   1021    1024    1024 1048576     20       50

Get a memory report for all running virtual machines formatted as a table.
.Example
PS C:\> get-content d:\MyVMs.txt | get-vmmemoryreport | Export-CSV c:\work\VMMemReport.csv -notypeinformation
Get virtual machine names from the text file MyVMs.txt and pipe them to Get-VMMemoryReport. The results are then exported to a CSV file.
.Example
PS C:\> get-vm -computer chi-hvr2 | get-vmmemoryreport | Sort Maximum | convertto-html -title "VM Memory Report" -css c:\scripts\blue.css -PreContent "<H2>Hyper-V Memory Report</H2>" -PostContent "<br>An assigned value of 0 means the virtual machine is not running." | out-file c:\work\vmmemreport.htm
Get a memory report for all virtual machines, sorted on the maximum memory property. This command then creates an HTML report.

.Notes
Last Updated: June 20, 2014
Version     : 2.0

.Link
Get-VM
Get-VMMemory
.Inputs
Strings
Hyper-V virtual machines
.Outputs
Custom object
#>

[cmdletbinding(DefaultParameterSetName="Name")]
Param(
[Parameter(Position=0,HelpMessage="Enter the name of a virtual machine",
ValueFromPipeline,ValueFromPipelineByPropertyName,
ParameterSetName="Name")]
[alias("Name")]
[ValidateNotNullorEmpty()]
[string]$VMName="*",
[Parameter(Position=0,Mandatory,HelpMessage="Enter the name of a virtual machine",
ValueFromPipeline,ValueFromPipelineByPropertyName,
ParameterSetName="VM")]
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

    if ($PSCmdlet.ParameterSetName -eq "Name") {
        Try {
            $VMs = Get-VM -name $VMName -ComputerName $computername -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to find VM $vmname on $computername"
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
        Write-Verbose "Querying memory for $($v.name) on $($computername.ToUpper())"
        $memorysettings = Get-VMMemory -VMName $v.name  -ComputerName $Computername -ErrorAction Stop

    if ($MemorySettings) {
    #all values are in MB
    $hash=[ordered]@{
        Computername = $v.ComputerName.ToUpper()
        Name = $V.Name
        Dynamic = $V.DynamicMemoryEnabled
        Assigned = $V.MemoryAssigned/1MB
        Demand = $V.MemoryDemand/1MB
        Startup = $V.MemoryStartup/1MB
        Minimum = $V.MemoryMinimum/1MB
        Maximum = $V.MemoryMaximum/1MB
        Buffer =  $memorysettings.buffer
        Priority = $memorysettings.priority
    }
    
    #write the new object to the pipeline
    New-Object -TypeName PSObject -Property $hash
    } #if $memorySettings found
    } #Try
    Catch {
        Throw $_
    } #Catch
    } #foreach $v in $VMs
} #process
End {
    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end
} #end Get-VMMemoryReport
