$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

Get-Mailbox -Identity dnessim

Get-RecoverableItems -Identity dnessim -SubjectConatins "Re: Audio Conference"