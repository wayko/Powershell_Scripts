﻿Uninstall-Module -name "pnp.powershell" -AllVersions -force -ErrorAction SilentlyContinue
    Install-packageprovider -name NuGet -MinimumVersion 2.8.5.201 -force -ErrorAction SilentlyContinue
    Install-Module -Name "PnP.PowerShell" -RequiredVersion 1.12.0 -Force -AllowClobber -ErrorAction SilentlyContinue
    Import-Module -name pnp.powershell -ErrorAction SilentlyContinue
    
    
    $O365ServiceAccount = "wpadmin@woodmontproperties.com"  
    $O365ServiceAccountPwd = "b@LLg@m3!@#"  
    $SharePointSiteURL = "https://woodmont.sharepoint.com/sites/TeamBackground"  
    $FileRelativeURL = "/sites/TeamBackground/Shared%20Documents/images/Woodmont-TeamsBackground-2024.jpg"
    # Change this SharePoint Site URL  
    $SharedDriveFolderPath = "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"  
    # Change the Document Library and Folder path  
    $SecurePass = ConvertTo-SecureString $O365ServiceAccountPwd -AsPlainText -Force
    $PSCredentials = New-Object System.Management.Automation.PSCredential($O365ServiceAccount, $SecurePass)  
    #Connecting to SharePoint site  
    Connect-PnPOnline -Url $SharePointSiteURL -Credentials $PSCredentials
    $userfolder = Get-ChildItem -path "c:\users" -Directory

    $guid = [guid]::NewGuid()
    $guid
    $guidfileName = "$guid.jpeg"
    $guidfileName
    $guidthumb = -join($guid, "_thumb.jpeg")
    $guidthumb
foreach ($user in $userfolder)
{
    $appdatafolder = "c:\users\$user\appdata\roaming\Microsoft\Teams\Backgrounds\Uploads"
    $newMSTeamsFolder = "c:\users\$user\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"
    Remove-Item -Path $appdatafolder\*.* -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $newMSTeamsFolder\*.* -Force -ErrorAction SilentlyContinue
    Get-PnPFile -Url $FileRelativeURL  -Path $appdatafolder -Filename "Woodmont-TeamsBackground-2024.jpg" -asFile -ErrorAction SilentlyContinue
    Get-PnPFile -Url $FileRelativeURL  -Path $newMSTeamsFolder -Filename $guidfileName -asFile -ErrorAction SilentlyContinue
    Get-PnPFile -Url $FileRelativeURL  -Path $newMSTeamsFolder -Filename $guidthumb -asFile -ErrorAction SilentlyContinue
}