#requires -version 3.0
#requires -module Hyper-V


Function Remove-OldVMSnapshot {

<#
.Synopsis
Remove old Hyper-V snapshots.
.Description
This command will find and remove snapshots older than a given number of days, the default is 90, on a Hyper-V server. You can limit the removal process to specific virtual machines as well as specific types of VM snapshots. 

This command will remove all child snapshots as well so use with caution. The command supports -Whatif and -Confirm.
.Example
PS C:\> Remove-OldVMSnapshot -VMName Ubunto-Demo -computername SERVER01

This command removed all snapshots for the Ubunto-Demo virtual machine on SERVER01 that is older than 90 days.
.Example
PS C:\> Remove-OldVMSnapshot -computername chi-hvr2 -days 14 -whatif
What if: Remove-VMSnapshot will remove snapshot "Profile Cleanup Test".

These are the snapshots older than 14 days on server CHI-HVR2 that would be removed.
.Example
PS C:\> Remove-OldVMSnapshot -computer chi-hvr2 -days 14 -confirm

Confirm
Are you sure you want to perform this action?
Remove-VMSnapshot will remove snapshot "Profile Cleanup Test".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):Y

Answering Y to the prompt will delete the snapshot.

.Notes
Last Updated: June 25, 2014
Version     : 1.0

.Link
Remove-VMSnapshot
#>
[cmdletbinding(SupportsShouldProcess,ConfirmImpact="High",DefaultParameterSetName="All")]

Param (
[Parameter(Position=0)]
[ValidateNotNullorEmpty()]
[string]$VMName="*",

[Parameter(Position=1)]
[ValidateScript({$_ -ge 1 })]
[Alias("days")]
[int]$Age=90,

[Parameter(Position=1,ParameterSetName="ByType")]
[ValidateNotNullorEmpty()]
[Alias("type")]
[Microsoft.HyperV.PowerShell.SnapshotType]$SnapshotType = "Standard",

[ValidateNotNullorEmpty()]
[Alias("CN")]
[string]$computername = $env:computername
)


Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  

#parameters for Get-VMSnapshot
$getParams= @{
Computername = $computername
ErrorAction = "Stop"
VMName = $VMName
}

if ($PSCmdlet.ParameterSetName -eq 'ByType') {
    Write-Verbose "Limiting snapshots to type $SnapshotType"
    $getParams.Add("SnapshotType",$SnapshotType)
}

Try {
  [datetime]$Cutoff = ((Get-Date).Date).AddDays(-$Age)
  Write-Verbose "Searching for snapshots equal to or older than $cutoff on $computername"
  $snaps = Get-VMSnapshot @getParams | Where {$_.CreationTime -le $Cutoff }
}
Catch {
    Throw $_
}

if ($snaps) {
    Write-Verbose "Found $($snaps.count) snapshots to be removed"
    $snaps |  Remove-VMSnapshot -IncludeAllChildSnapshots 
    
}

Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"

} #end function
