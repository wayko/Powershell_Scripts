
Connect-ExchangeOnline -UserPrincipalName atlanticadmin@maillie.com

$Roomaccount = "newcastletrainingroom@maillie.com"

Set-CalendarProcessing -Identity $Roomaccount -ProcessExternalMeetingMessages $True

get-inboundconnector