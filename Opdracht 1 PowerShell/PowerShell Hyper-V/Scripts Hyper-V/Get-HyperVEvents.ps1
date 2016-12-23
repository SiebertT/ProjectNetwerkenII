#requires -version 3.0

Function Get-HyperVEvents {
<#
.Synopsis
Get errors and warnings from Hyper-V Operational logs.
.Description
This command will search a specified server for all Hyper-V related Windows Operational logs and get all errors and warnings that have been recorded in the specified number of days which is 7 by default.

The command uses PowerShell remoting to query event logs and resolve SIDs to account names. The remote event log management firewall exception is not required to use the command.
.Example
PS C:\> Get-HyperVEvents -Days 30 -computer CHI-HVR2 | Select LogName,TimeCreated,Type,ID,Message,Username | Out-Gridview -title "Events"

Get all errors and warnings within the last 30 days on server CHI-HVR2 and display with Out-Gridview.

.Notes
Last Updated: June 25, 2014
Version     : 2.0

.Link
Get-WinEvent
Get-Eventlog
.Inputs
[String]
.Outputs
[System.Diagnostics.Eventing.Reader.EventLogRecord]
Technically this will be a deserialized version of this object.
#>

[cmdletbinding()]

Param(
[Parameter(Position=0,HelpMessage="Enter the name of a Hyper-V host")]
[ValidateNotNullorEmpty()]
[Alias("CN","PSComputername")]
[string]$Computername=$env:COMPUTERNAME,
[ValidateScript({$_ -ge 1})]
[int]$Days=7,
[Alias("RunAs")]
[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
)

Write-Verbose "Starting $($MyInvocation.MyCommand)"
Write-Verbose "Querying Hyper-V logs on $($computername.ToUpper())"

#define a hash table of parameters to splat to Invoke-Command
$icmParams=@{
ErrorAction="Stop"
ErrorVariable="MyErr"
Computername=$Computername
HideComputername=$True
}

if ($credential.username) {
    Write-Verbose "Adding a credential for $($credential.username)"
    $icmParams.Add("Credential",$credential)
}

#define the scriptblock to run remotely and get events using Get-WinEvent
$sb = {

Param([string]$Verbose="SilentlyContinue")

#set verbose preference in the remote scriptblock
$VerbosePreference=$Verbose

#calculate the cutoff date
$start = (Get-Date).AddDays(-$using:days)
Write-Verbose "Getting errors since $start"

#construct a hash table for the -FilterHashTable parameter in Get-WinEvent
$filter= @{
Logname= "Microsoft-Windows-Hyper-V*"
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
    $_ | Add-Member -MemberType AliasProperty -Name "Type" -Value "LevelDisplayName"
         
    $_ | Add-Member -MemberType ScriptProperty -Name Username -Value {
    [WMI]$Resolved = "root\cimv2:Win32_SID.SID='$($this.UserID)'"
        #write the resolved name to the pipeline
        "$($Resolved.ReferencedDomainName)\$($Resolved.Accountname)"
    } -PassThru
    } 
}
Catch {
    Write-Warning "No matching events found."
}

} #close scriptblock

#add the scriptblock to the parameter hashtable for Invoke-Command
$icmParams.Add("Scriptblock",$sb)

if ($VerbosePreference -eq "Continue") {
    #if this command was run with -Verbose, pass that to the scriptblock
    #which will be running remotely.
    Write-Verbose "Adding verbose scriptblock argument"
    $sbArgs="Continue"
    $icmParams.Add("Argumentlist",$sbArgs)
}

Try {
    #invoke the scriptblock remotely and pass properties to the pipeline, except
    #for the RunspaceID from the temporary remoting session which we don't need.
    Invoke-Command @icmParams 
}
Catch {
    #Invoke-Command failed
    Write-Warning "Failed to connect to $($computername.ToUpper())"
    Write-Warning $MyErr.errorRecord
    #bail out of the function and don't do anything else
    Return
}

#All done here
Write-Verbose "Ending $($MyInvocation.MyCommand)"

} #end function