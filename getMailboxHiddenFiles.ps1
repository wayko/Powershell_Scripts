#company email address# 
$clientEmail = "atlanticIT@dynamicaqs.onmicrosoft.com" 
#User email address#
$userMailbox = "DWiser@dynamicaqs.com" 
Connect-ExchangeOnline -UserPrincipalName $clientEmail
Connect-IPPSSession -UserPrincipalName $clientEmail

#Get User mailbox size#
$ExchangeGUID = Get-Mailbox $userMailbox  | Select-Object -ExpandProperty ExchangeGUID
Get-MailboxFolderStatistics -Identity "$ExchangeGUID" -IncludeAnalysis -FolderScope RecoverableItems | Format-Table Name,ItemsInFolder,FolderSize,*Subject*

#Disable the single item recovery#
Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $false
Start-ManagedFolderAssistant -Identity "$ExchangeGUID" -HoldCleanup

#Check MFA has been ran#
$log = Export-MailboxDiagnosticLogs -Identity DWiser@dynamicaqs.com  -ExtendedProperties
$xml = [xml]($Log.MailboxLog)
$xml.Properties.MailboxTable.Property | ? {$_.Name -like "ELC*"}

Get-MailboxFolderStatistics -Identity "$ExchangeGUID" -IncludeAnalysis -FolderScope RecoverableItems | Format-Table Name,ItemsInFolder,FolderSize,*Subject*

#Enable the single item recovery#
Set-Mailbox -Identity "$ExchangeGUID" -SingleItemRecoveryEnabled $true


Get-MailboxFolderStatistics $userMailbox -FolderScope RecoverableItems | FL Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders



Start-ComplianceSearch
New-ComplianceSearchAction -SearchName "RecoverableItems" -Purge -PurgeType HardDelete