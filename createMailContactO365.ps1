$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
Set-OrganizationConfig -OnlineMeetingsByDefaultEnabled $false
Get-OrganizationConfig | Select OnlineMeetingsByDefaultEnabled
Import-CSV C:\Contacts.csv|%{New-MailContact -Name $_.Email -ExternalEmailAddress $_.Email}



