Connect-SPOService -url https://chcanys-admin.sharepoint.com/

Get-SPOSite -Limit ALL | Tee-Object f:\sitelist.csv -Append

Get-SPOSite -Filter { Url -like "commondrive" }

$sites = get-sposite -Identity https://chcanys.sharepoint.com/sites/CommonDrive

foreach($site in $sites){
    $site | Select -Property Template, StorageUsageCurrent, StorageQuota, LastContentModifiedDate, sharingcapability


}