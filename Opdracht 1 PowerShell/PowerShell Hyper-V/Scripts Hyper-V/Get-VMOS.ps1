#requires -version 3.0

Function Get-VMOS {

<#
.Synopsis
Get the installed Windows operating system on a virtual machine.
.Description
This command will display the installed Windows operating system on a Hyper-V virtual machine. The virtual machine must be running.

The function uses WMI to query remote computers.
.Example
PS C:\> Get-VMOS CHI-core01 -Computername chi-hvr2

VMName                     OperatingSystem                   Computername                     
------                     ---------------                   ------------                     
CHI-CORE01                 Windows Server 2012 R2 Datacenter CHI-HVR2  

Get a single virtual machine operating system.
.Example
PS C:\> get-vm -computername chi-hvr2 | where {$_.state -eq 'running'} | get-vmos

VMName                      OperatingSystem                   Computername                     
------                      ---------------                   ------------                     
CHI-CORE01                  Windows Server 2012 R2 Datacenter CHI-HVR2                         
CHI-DC04                    Windows Server 2012 Datacenter    CHI-HVR2                         
CHI-FP02                    Windows Server 2012 R2 Standard   CHI-HVR2                         
CHI-Win81                   Windows 8.1 Pro                   CHI-HVR2                         

Get operating system information for all running virtual machines.

.Notes
Last Updated: June 23, 2014
Version     : 2.0

.Link
Get-WMIObject
#>

[cmdletbinding()]
Param(
[Parameter(Position=0,HelpMessage="Enter the name of a virtual machine",
ValueFromPipeline,ValueFromPipelinebyPropertyName)]
[ValidateNotNullorEmpty()]
[Alias("Name")]
[string]$VMName="*",
[Parameter(ValueFromPipelinebyPropertyName)]
[string]$Computername=$env:COMPUTERNAME
)

Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  
} #begin


Process {

Write-Verbose "Querying virtual machines on $($Computername.ToUpper())"

$wmiParam=@{
Namespace= "root/virtualization/v2"
ClassName= "Msvm_VirtualSystemManagementService"
ComputerName= $Computername
errorAction= "Stop"
errorVariable= "myErr"
}

Try {
   $vsm = Get-WmiObject @wmiparam
}
Catch {
  $myerr.errorrecord.exception.message
}

#modify the parameter hash
$wmiParam.ClassName= "MSVM_Computersystem"
if ($VMName -eq "*") {
  $filter = "Caption='Virtual Machine'"

}
elseif ($VMName -match "\*") {
    #replace * with %
    $elementname = $VMName.Replace("*","%")
    $filter = "elementname LIKE '$elementname'"
}
else {
    $filter = "elementname='$VMName'"
}

$wmiParam.filter= $filter
Write-verbose "Querying virtual machine $VMName"
write-Verbose ($wmiParam | Out-String)

Try {
    $vm = Get-WmiObject @wmiparam
}
Catch {
  $myerr.errorrecord.exception.message
}

if ($vm) {

#get virtual system data and filter out checkpoints
$vsd = $vm.GetRelated("MSVM_VirtualSystemSettingData") | where {$_.Description -notmatch "^Checkpoint"}

#an array of items to get
#http://msdn.microsoft.com/en-us/library/hh850062(v=vs.85).aspx
[uint32[]]$requested = @(1,106)

$result = $vsm.GetSummaryInformation($vsd,$requested)

#display the result
$result.summaryinformation | 
select @{Name="VMName";Expression={$_.Elementname}},
@{Name="OperatingSystem";Expression={$_.GuestOperatingSystem}},
@{Name="Computername";Expression={$vsm.pscomputername}}

}
else {
  Write-Warning "Failed to find virtual machine $VMName"
}

} #Process

End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end

} #end function