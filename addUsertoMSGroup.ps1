Install-Module -Name ExchangeOnlineManagement

 

Connect-ExchangeOnline

 

Remove-RecipientPermission "group" -AccessRights SendAs -Trustee email

 

 

Add-RecipientPermission "group" -AccessRights SendAs -Trustee email

 