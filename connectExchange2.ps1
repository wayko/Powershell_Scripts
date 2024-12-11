$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $O365Session -AllowClobber

Connect-ExchangeOnline
Get-Inboxrule -Mailbox  pgoldhamer@kgglaw.com
