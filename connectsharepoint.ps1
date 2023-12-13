	
Install-Module Microsoft.Online.SharePoint.PowerShell 
Update-Module -Name Microsoft.Online.SharePoint.PowerShell


connect-sposervice  -url https://specialtyfood-admin.sharepoint.com
$sites = get-SpOSite -Limit All
$ato = "email"
foreach($site in $sites)
{
   Get-sposite  -identity $site.url -Detailed

}
$sites

$OwnersGroup = Get-PnPGroupMember