Install-Module -Name ExchangeOnlineManagement -Force

Connect-ExchangeOnline -UserPrincipalName josystem@edisonlearning.com email
Get-ADDomain -Identity edisonschools.net | Outcd -File c:\temp\domain.tx


Get-DistributionGroup -Identity info | Select Name,PrimarySmtpAddress,
  @{L="EmailAddresses";E={$_.EmailAddresses | ? {$_.PrefixString -ceq "aliases"} | % {$_.aliases}}} 

  Set-DistributionGroup -Identity "List name" -Alias @{remove="alias@contoso.com"}
  Set-DistributionGroup -Identity "info" -Alias @{remove="info@thetoddgroupinc.com"}
Connect-MsolService 
$users = @(
"email1",
"email2"
)

foreach($user in $users)
{
  $user
  set-MSOLUser -UserPrincipalName $user -PasswordNeverExpires $true 
  $user
}


Get-DistributionGroup   -ResultSize unlimited | select displayname,emailaddresses
 

Set-OrganizationConfig -OnlineMeetingsByDefaultEnabled $false

Get-MailboxFolderPermission -Identity  gskimmigration:\ -user email
Get-MailboxFolderPermission -Identity  gskimmigration:\ -user email

Get-MailboxFolderPermission -Identity haleonimmigration:\ -user email
Get-MailboxFolderPermission -Identity  haleonimmigration:\ -user email



Add-MailboxFolderPermission -Identity gskimmigration:\ -User "email" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity gskimmigration:\Inbox -User "email" -AccessRights Reviewer

Add-MailboxFolderPermission -Identity haleonimmigration:\ -User "email" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity haleonimmigration:\Inbox -User "email" -AccessRights Reviewer

Add-MailboxFolderPermission -Identity gskimmigration:\ -User "email" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity gskimmigration:\Inbox -User "email" -AccessRights Reviewer

Add-MailboxFolderPermission -Identity haleonimmigration:\ -User "email" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity haleonimmigration:\Inbox -User "email" -AccessRights Reviewer



Get-MailboxStatistics -Identity email | Select *TotalItemSize*


Get-Mailbox -Identity 


$ExchangeGUID = Get-Mailbox email | Select-Object -ExpandProperty ExchangeGUID
Get-MailboxFolderStatistics -Identity "$ExchangeGUID" -IncludeAnalysis -FolderScope RecoverableItems | Format-Table Name,ItemsInFolder,FolderSize,*Subject*


$ExchangeGUID = Get-Mailbox email | Select-Object -ExpandProperty ExchangeGUID
Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $false


$ExchangeGUID = Get-Mailbox email  | Select-Object -ExpandProperty ExchangeGUID
Start-ManagedFolderAssistant -Identity "$ExchangeGUID" -HoldCleanup


$log = Export-MailboxDiagnosticLogs -Identity email  -ExtendedProperties
$xml = [xml]($Log.MailboxLog)
$xml.Properties.MailboxTable.Property | ? {$_.Name -like "ELC*"}


$ExchangeGUID = Get-Mailbox email  | Select-Object -ExpandProperty ExchangeGUID
Get-MailboxFolderStatistics -Identity "$ExchangeGUID" -IncludeAnalysis -FolderScope RecoverableItems | Format-Table Name,ItemsInFolder,FolderSize,*Subject*


Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $true