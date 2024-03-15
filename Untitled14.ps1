#Disable Email 
PolicySet-RemoteMailbox User1 -EmailAddressPolicyEnabled $false
Set-RemoteMailbox User1 -PrimarySmtpAddress "User1@My-good-address.com"