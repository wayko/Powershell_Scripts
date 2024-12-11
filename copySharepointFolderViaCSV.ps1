foreach($id in $folderID)
{  
$SourceURL= "Shared Documents/DocumentsLive/Sales Header/" + $id.ID
$TargetURL = "Shared Documents/SupplyPike2/" + $id.ID
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -interactive
try
{
#move files in sharepoint online using powershell
Copy-PnPFile -SourceUrl $SourceURL -TargetUrl $TargetURL -Force
write-host $SourceURL " has been copied to " $TargetURL
}
catch
{
    $SourceURL +" was not found"
     $id.ID | Tee-Object C:\users\atoadmin\Desktop\missingFromSaleHeader.csv -Append
}

}



