Connect-ExchangeOnline -UserPrincipalName atlanticadmin@maillie.com atlanticIT@dynamicaqs.onmicrosoft.com atoadmin@klaskolaw.onmicrosoft.com

Connect-ExchangeOnline -UserPrincipalName atlanticadmin@maillie.com
Connect-MsolService 
$users = @(
"LimerickTrainingRM144@maillie.com",
"LimerickTrainingRM145@maillie.com",
"LimerickConferenceRM247@Maillie.com",
"LimerickConferenceRM114@Maillie.com",
"LimerickHuddleRM219@Maillie.com",
"LimerickHuddleRM120@Maillie.com",
"newcastletrainingroom@Maillie.com",
"newcastleboardroom@Maillie.com",
"wcsmallcr@Maillie.com",
"wclargecr@Maillie.com",
"wcmedcr@Maillie.com"
)

foreach($user in $users)
{
  $user
  set-MSOLUser -UserPrincipalName $user -PasswordNeverExpires $true 
  $user
}
 

Set-OrganizationConfig -OnlineMeetingsByDefaultEnabled $false

Get-MailboxFolderPermission -Identity  gskimmigration:\ -user swagstaff@klaskolaw.com
Get-MailboxFolderPermission -Identity  gskimmigration:\ -user hsawyer@klaskolaw.com

Get-MailboxFolderPermission -Identity haleonimmigration:\ -user swagstaff@klaskolaw.com
Get-MailboxFolderPermission -Identity  haleonimmigration:\ -user hsawyer@klaskolaw.com



Add-MailboxFolderPermission -Identity gskimmigration:\ -User "hsawyer@klaskolaw.com" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity gskimmigration:\Inbox -User "hsawyer@klaskolaw.com" -AccessRights Reviewer

Add-MailboxFolderPermission -Identity haleonimmigration:\ -User "hsawyer@klaskolaw.com" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity haleonimmigration:\Inbox -User "hsawyer@klaskolaw.com" -AccessRights Reviewer

Add-MailboxFolderPermission -Identity gskimmigration:\ -User "swagstaff@klaskolaw.com" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity gskimmigration:\Inbox -User "swagstaff@klaskolaw.com" -AccessRights Reviewer

Add-MailboxFolderPermission -Identity haleonimmigration:\ -User "swagstaff@klaskolaw.com" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity haleonimmigration:\Inbox -User "swagstaff@klaskolaw.com" -AccessRights Reviewer



Get-MailboxStatistics -Identity DWiser@dynamicaqs.com | Select *TotalItemSize*


Get-Mailbox -Identity 


$ExchangeGUID = Get-Mailbox DWiser@dynamicaqs.com | Select-Object -ExpandProperty ExchangeGUID
Get-MailboxFolderStatistics -Identity "$ExchangeGUID" -IncludeAnalysis -FolderScope RecoverableItems | Format-Table Name,ItemsInFolder,FolderSize,*Subject*


$ExchangeGUID = Get-Mailbox DWiser@dynamicaqs.com | Select-Object -ExpandProperty ExchangeGUID
Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $false


$ExchangeGUID = Get-Mailbox DWiser@dynamicaqs.com  | Select-Object -ExpandProperty ExchangeGUID
Start-ManagedFolderAssistant -Identity "$ExchangeGUID" -HoldCleanup


$log = Export-MailboxDiagnosticLogs -Identity DWiser@dynamicaqs.com  -ExtendedProperties
$xml = [xml]($Log.MailboxLog)
$xml.Properties.MailboxTable.Property | ? {$_.Name -like "ELC*"}


$ExchangeGUID = Get-Mailbox DWiser@dynamicaqs.com  | Select-Object -ExpandProperty ExchangeGUID
Get-MailboxFolderStatistics -Identity "$ExchangeGUID" -IncludeAnalysis -FolderScope RecoverableItems | Format-Table Name,ItemsInFolder,FolderSize,*Subject*


Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $true