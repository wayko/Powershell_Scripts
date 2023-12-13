install-module pnp.powershell
Import-Module PnP.Powershell


$sites = import-csv -path F:\specialtyfood.csv


 foreach($site in $sites){
#Connect to PnP Online
Connect-PnPOnline -Url $Site.url -Interactive



 
# Retrieve document libraries and their retention policies
$libraries = Get-PnPList  -IncludeProperties EnableRetention,RetentionId,RetentionPeriod,RetentionType -Template DocumentLibrary

foreach($library in $libraries)
{
    $library.title
}
 
# Export the results to a CSV file
#$libraries | Select-Object Title, EnableRetention, RetentionId, RetentionPeriod, RetentionType | Export-Csv -Path "F:\DocumentLibraries.csv" -NoTypeInformation

}

