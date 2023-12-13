$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

$userMailbox = Get-Mailbox -ResultSize Unlimited

Foreach($mailbox in $userMailbox)
{
   
        if($mailbox.Alias -ne "chernandez" -and $mailbox.Alias -ne "jortiz")
        {
            
        }
        else
        {
            $mailbox.Alias
        }
       

}