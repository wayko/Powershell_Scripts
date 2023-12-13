    $O365ServiceAccount = "email"  
    $O365ServiceAccountPwd = "password"  
    $SharePointSiteURL = "https://woodmont.sharepoint.com/sites/TeamBackground"  
    $FileRelativeURL = "/sites/TeamBackground/Shared%20Documents/images/Woodmont-TeamsBackground-202310.jpg"
    $FileRelativeURLThumbnail = "/sites/TeamBackground/Shared%20Documents/images/Woodmont-TeamsBackground-202310-thumbnail.jpg"
    # Change this SharePoint Site URL  
    $SharedDriveFolderPath = "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"  
    # Change the Document Library and Folder path  
    $SecurePass = ConvertTo-SecureString $O365ServiceAccountPwd -AsPlainText -Force
    $PSCredentials = New-Object System.Management.Automation.PSCredential($O365ServiceAccount, $SecurePass)  
    #Connecting to SharePoint site  
    Connect-PnPOnline -Url $SharePointSiteURL -Credentials $PSCredentials


    Remove-Item -Path $SharedDriveFolderPath\*.* -Force
    Get-PnPFile -Url $FileRelativeURL  -Path $SharedDriveFolderPath -Filename "Woodmont-TeamsBackground-202310.jpg" -asFile
    Get-PnPFile -Url $FileRelativeURLThumbnail  -Path $SharedDriveFolderPath -Filename "Woodmont-TeamsBackground-202310-thumbnail.jpg" -asFile

 

