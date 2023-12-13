#Launch PowerShell as Administrator (IMPORTANT)

#Setup powershell to run remote scripts. Only needed if you've never installed or imported a module to your PowerShell
Set-ExecutionPolicy RemoteSigned

#Install and import the AIPService module. This is only needed if you have never connected before.
Install-module AIPService
Import-module AIPService

#Connect to AADRMService. You will need to use the Global Admin creds for the tenant in question.
Connect-AIPService

#Activate the service.
Enable-AIPService

#Retrieve the configuration information needed for message encryption from MS servers.
$rmsConfig = Get-AIPServiceConfiguration
$licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl

#Disconnect from the service.
Disconnect-AIPService

#Install the exchange online service. This is only needed if you have never connected before.
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement

#Create a remote PowerShell session and connect to Exchange Online. You will need to use the Global Admin creds for the tenant in question.
Connect-ExchangeOnline 

#Collect IRM configuration for Office 365.
$irmConfig = Get-IRMConfiguration
$list = $irmConfig.LicensingLocation
if (!$list) { $list = @() }
if (!$list.Contains($licenseUri)) { $list += $licenseUri }

#Enable message encryption for Office 365.
Set-IRMConfiguration -LicensingLocation $list
Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $true