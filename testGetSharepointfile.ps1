#Parameters
$SiteURL= "https://woodmont.sharepoint.com/sites/TeamBackground"
$FileRelativeURL = "/sites/TeamBackground/Shared Documents/images"
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
   
#Get the Contents of the File
$File = Get-PnPFile -Url $FileRelativeURL -AsString
 
Write-host $File

