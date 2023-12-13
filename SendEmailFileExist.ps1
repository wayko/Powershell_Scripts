$Folders = Get-ChildItem -Path F:\Test -Recurse

foreach($Folder in $Folders){
 $directory = Get-Item -Path $Folder.FullName 
Try
{
if(!($directory.EnumerateFileSystemInfos() | select -First 1))
{
    "$directory is empty"
}
else
{
  $SmtpServer = 'smtp-mail.outlook.com'
$SmtpUser = 'user'
$smtpPassword = 'paswword'
$MailtTo = 'email'
$Mailbcc = 'email'
$MailFrom = 'email'
$MailSubject = "There are file/s in $directory" 
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
$portNumber =587

 Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -SmtpServer $SmtpServer -UseSsl -Credential $Credentials -port $portNumber 
}
}
catch
{
}
}