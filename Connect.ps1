$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUrihttps://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
     Set-OrganizationConfig -OnlineMeetingsByDefaultEnabled $false
     Get-OrganizationConfig | Select OnlineMeetingsByDefaultEnabled


    