$sites = import-csv -path F:\specialtyfood.csv
Import-Module PnP.Powershell
Connect-PnPOnline -Url https://specialtyfood.sharepoint.com -Credentials (Get-Credential)

 foreach($site in $sites){
#Connect to PnP Online
Connect-PnPOnline -Url $Site.url -Interactive
$libraryUrl = $site.url+"/Documents"
$retentionPolicies = Get-PnPProvisioningTemplate -Handlers Retention

# Loop through the retention policies and output the retention length
foreach ($retentionPolicy in $retentionPolicies.RetentionPolicies) {
    Write-Output "Retention Policy Name: $($retentionPolicy.DisplayName)"
    Write-Output "Retention Length: $($retentionPolicy.DurationInDays) days"
}

 }