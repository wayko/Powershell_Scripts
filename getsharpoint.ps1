# Connect to SharePoint Online
Connect-PnPOnline -Url https://specialtyfood-admin.sharepoint.com -Credentials (Get-Credential)
 
# Retrieve document libraries and their retention policies
$libraries = Get-PnPList -IncludeProperties EnableRetention,RetentionId,RetentionPeriod,RetentionType -Template DocumentLibrary
 
# Export the results to a CSV file
$libraries | Select-Object Title, EnableRetention, RetentionId, RetentionPeriod, RetentionType | Export-Csv -Path "C:\temp\DocumentLibraries.csv" -NoTypeInformation