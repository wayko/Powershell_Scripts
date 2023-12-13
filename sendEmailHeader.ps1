

$SmtpServer = 'smtp-mail.outlook.com'
$SmtpUser = 'email'
$smtpPassword = 'password'
$MailtTo = 'email'
$MailFrom = 'email'
$attachment = "f:\dns.txt"
$MailSubject = "This is a test" 
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
$portNumber = 587

 Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -SmtpServer $SmtpServer -UseSsl -Credential $Credentials -port $portNumber -Attachments $attachment