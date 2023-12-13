$O365ServiceAccount = "email"  
$O365ServiceAccountPwd = "password"  
#Variables for Processing
$adminSite = "https://woodmont-admin.sharepoint.com/"
$SiteUrl = "https://woodmont.sharepoint.com/sites/TeamBackground"
$FileRelativeURL ="/sites/TeamBackground/Shared%20Documents/images/Woodmont-TeamsBackground-202310.jpg"
$FileRelativeURLThumbnail = "/sites/TeamBackground/Shared%20Documents/images/Woodmont-TeamsBackground-202310-thumbnail.jpg"
$SecurePass = ConvertTo-SecureString $O365ServiceAccountPwd -AsPlainText -Force
$PSCredentials = New-Object System.Management.Automation.PSCredential($O365ServiceAccount, $SecurePass)  
Connect-SPOService -Url $adminSite -credential $PSCredentials
Get-sposite -Identity $siteurl