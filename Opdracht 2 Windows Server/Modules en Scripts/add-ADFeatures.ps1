#Install AD DS, DNS and GPMC
start-job -Name addFeature -ScriptBlock {
  Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools                                                                  
  Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools                                    
  Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools   }
Wait-Job -Name addFeature
