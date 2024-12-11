#for ($SearchStatus;$SearchStatus -notlike "Completed";){ #Wait then check if the search is complete, loop until complete
   # Start-Sleep -s 10
    #$SearchStatus = Get-ComplianceSearch $SearchName | Select-Object -ExpandProperty Status #Get the status of the search
    #Write-Host -NoNewline "." # Show some sort of status change in the terminal
#}


#Start-Sleep -s 15
#New-ComplianceSearchAction -SearchName $SearchName -Export -Format FxStream -ExchangeArchiveFormat PerUserPst -Scope BothIndexedAndUnindexedItems -EnableDedupe $true -Confirm:$false
#Start-Sleep -s 60 # Arbitrarily wait 5 seconds to give microsoft's side time to create the SearchAction before the next commands try to run against it. I /COULD/ do a for loop and check, but it's really not worth it.

# Check if the export tool is installed for the user, and download if not.
#While (-Not ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter microsoft.office.client.discovery.unifiedexporttool.exe -Recurse).FullName | Where-Object{ $_ -notmatch "_none_" } | Select-Object -First 1)){
 #   Write-Host "Downloading Unified Export Tool ."
  #  Write-Host "This is installed per-user by the Click-Once installer."
   # $Manifest = "https://complianceclientsdf.blob.core.windows.net/v16/Microsoft.Office.Client.Discovery.UnifiedExportTool.application"
    #$ElevatePermissions = $true
    #Try {
     #   Add-Type -AssemblyName System.Deployment
      #  Write-Host "Starting installation of ClickOnce Application $Manifest "
       # $RemoteURI = [URI]::New( $Manifest , [UriKind]::Absolute)
        #if (-not  $Manifest){
        #    throw "Invalid ConnectionUri parameter '$ConnectionUri'"
        #}
        #$HostingManager = New-Object System.Deployment.Application.InPlaceHostingManager -ArgumentList $RemoteURI , $False
        #Register-ObjectEvent -InputObject $HostingManager -EventName GetManifestCompleted -Action { 
         #   new-event -SourceIdentifier "ManifestDownloadComplete"
        #} | Out-Null
        #Register-ObjectEvent -InputObject $HostingManager -EventName DownloadApplicationCompleted -Action { 
         #   new-event -SourceIdentifier "DownloadApplicationCompleted"
        #} | Out-Null
        #$HostingManager.GetManifestAsync()
        #$event = Wait-Event -SourceIdentifier "ManifestDownloadComplete" -Timeout 15
        #if ($event ) {
         #   $event | Remove-Event
           # Write-Host "ClickOnce Manifest Download Completed"
            #$HostingManager.AssertApplicationRequirements($ElevatePermissions)
            #$HostingManager.DownloadApplicationAsync()
            #$event = Wait-Event -SourceIdentifier "DownloadApplicationCompleted" -Timeout 60
            #if ($event ) {
             #   $event | Remove-Event
             #   Write-Host "ClickOnce Application Download Completed"
            #}
            #else {
             #   Write-error "ClickOnce Application Download did not complete in time (60s)"
            #}
        #}
      #  else {
       #     Write-error "ClickOnce Manifest Download did not complete in time (15s)"
        #}
    #}
    #finally {
     #   Get-EventSubscriber|? {$_.SourceObject.ToString() -eq 'System.Deployment.Application.InPlaceHostingManager'} | Unregister-Event
    #}
#}
#write-host "Application is already installed"
#Start-Sleep -s 600

# Find the Unified Export Tool's location and create a variable for it
#$ExportExe = ((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter microsoft.office.client.discovery.unifiedexporttool.exe -Recurse).FullName | Where-Object{ $_ -notmatch "_none_" } | Select-Object -First 1)

# Gather the URL and Token from the export in order to start the download
# We only need the ContainerURL and SAS Token at a minimum but we're also pulling others to help with tracking the status of the export.
#$ExportName = $SearchName + "_Export"
#$ExportDetails = Get-ComplianceSearchAction -Identity $ExportName -IncludeCredential -Details # Get details for the export action
# This method of splitting the Container URL and Token from $ExportDetails is thanks to schmeckendeugler from reddit: https://www.reddit.com/r/PowerShell/comments/ba4fpu/automated_download_of_o365_inbox_archive/
# I was using Convert-FromString before, which was slow and terrible. His way is MUCH better.
#$ExportDetails = $ExportDetails.Results.split(";")
#$ExportContainerUrl = $ExportDetails[0].trimStart("Container url: ")
#$ExportSasToken = $ExportDetails[1].trimStart(" SAS token: ")
#$ExportEstSize = ($ExportDetails[18].TrimStart(" Total estimated bytes: ") -as [double])
#$ExportTransferred = ($ExportDetails[20].TrimStart(" Total transferred bytes: ") -as [double])
#$ExportProgress = $ExportDetails[22].TrimStart(" Progress: ").TrimEnd("%")
#$ExportStatus = $ExportDetails[25].TrimStart(" Export status: ")

# Download the exported files from Office 365
#Write-Host "Initiating download"
#Write-Host "Saving export to: " + $ExportLocation
#$Arguments = "-name ""$SearchName""","-source ""$ExportContainerUrl""","-key ""$ExportSasToken""","-dest ""$ExportLocation""","-trace true"
#Start-Process -FilePath "$ExportExe" -ArgumentList $Arguments

#while(Get-Process microsoft.office.client.discovery.unifiedexporttool -ErrorAction SilentlyContinue){
 #   $Downloaded = Get-ChildItem $ExportLocation\$SearchName -Recurse | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum
  #  Write-Progress -Id 1 -Activity "Export in Progress" -Status "Complete..." -PercentComplete $ExportProgress
   # if ("Completed" -notlike $ExportStatus){Write-Progress -Id 2 -Activity "Download in Progress" -Status "Estimated Complete..." -PercentComplete ($Downloaded/$ExportEstSize*100) -CurrentOperation "$Downloaded/$ExportEstSize bytes downloaded."}
    #else {Write-Progress -Id 2 -Activity "Download in Progress" -Status "Complete..." -PercentComplete ($Downloaded/$ExportEstSize*100) -CurrentOperation "$Downloaded/$ExportTransferred bytes downloaded."}
    #Start-Sleep 60
    #$ExportDetails = Get-ComplianceSearchAction -Identity $ExportName -IncludeCredential -Details # Get details for the export action
    #$ExportDetails = $ExportDetails.Results.split(";")
    #$ExportEstSize = ($ExportDetails[18].TrimStart(" Total estimated bytes: ") -as [double])
    #$ExportTransferred = ($ExportDetails[20].TrimStart(" Total transferred bytes: ") -as [double])
    #$ExportProgress = $ExportDetails[22].TrimStart(" Progress: ").TrimEnd("%")
    #$ExportStatus = $ExportDetails[25].TrimStart(" Export status: ")
    #Write-Host -NoNewline " ."
#}
