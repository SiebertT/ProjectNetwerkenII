#requires -version 3.0
#requires -module Hyper-V

Param(
[string[]]$VMName="*",
[string]$Computername=$env:computername)

Invoke-Command -scriptblock {
Get-VMSnapshot -VMName $using:VMName | 
Select Computername,VMName,Name,SnapshotType,CreationTime,
@{Name="Age";Expression={ (Get-Date) - $_.CreationTime }},
@{Name="SizeGB";
Expression = { ($_.HardDrives | Get-Item | Measure-Object -Property length -sum).sum/1GB }}
} -computername $computername -HideComputerName | Select * -ExcludeProperty RunspaceID

