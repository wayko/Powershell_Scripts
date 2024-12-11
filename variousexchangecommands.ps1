$email = "josystem@edisonlearning.com"
$password = "Aveeno09!"
$SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
$Credential  = New-Object System.Management.Automation.PSCredential $email,$SecuredPassword
Connect-IPPSSession  -Credential $Credential
Connect-MsolService -Credential $Credential
Connect-ExchangeOnline -Credential $Credential
search-mailbox -identity josystem@edisonlearning.com -searchquery {received >= 05/20/2024} -deletecontent
search-mailbx

New-ComplianceSearch -Name "Remove older than 30 days messages" -ExchangeLocation josystem@edisonlearning.com -ContentMatchQuery "(Received >= 05/20/2024)"
Start-ComplianceSearch -Identity "Remove older than 30 days messages"
start-sleep -Seconds 60
New-ComplianceSearchAction -SearchName "Remove older than 30 days messages" -Purge -PurgeType SoftDelete -Confirm:$false

$users = import-csv -path C:\temp\Users.csv

foreach($user in $users)
{
$name = $user.Directory

#Start-ManagedFolderAssistant -Identity Alisha.Zak
#Get-MailboxStatistics -Identity $user.Directory | select DisplayName,TotalItemSize |sort-object DisplayName |export-csv c:\temp\mailboxsize.csv -Append
get-mailbox $name |select-object name,alias | sort-object name | export-csv c:\temp\alias.csv -append
}
$MRMLogs = [xml] ((Export-MailboxDiagnosticLogs josystem -ExtendedProperties).mailboxlog)
$MRMLogs.Properties.MailboxTable.Property | ? {$_.Name -like “*ELC*”}
$all = get-mailbox
foreach($mailbox in $all)
{
Get-MailboxFolderStatistics $mailbox.Alias |select DisplayName,TotalItemSize

}
Get-Mailbox |select-object Alias |sort-object Alias |Tee-Object c:\temp\users3.csv -Append


Get-Mailbox josystem@edisonlearning.com | FL RetentionPolicy


Get-Mailbox | Get-MailboxStatistics | Select-Object DisplayName, TotalItemSize, ItemCount |export-csv c:\temp\mailboxsize2.csv -Append 


$groups = Get-DistributionGroup |Select-Object name | Sort-Object name

foreach($member in $groups)
{
  $member.Name |tee-object c:\temp\groupmember.csv -Append
  Get-DistributionGroupmember $member.Name|select-object name | tee-object c:\temp\groupmember.csv -Append
  

}


$Groups = Get-UnifiedGroup -ResultSize Unlimited

$Groups | ForEach-Object {
$group = $_
Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members -ResultSize Unlimited | ForEach-Object {
      New-Object -TypeName PSObject -Property @{
       Group = $group.DisplayName
       Member = $_.Name
       EmailAddress = $_.PrimarySMTPAddress
       RecipientType= $_.RecipientType
}}} | Export-CSV "c:\temp\Office365GroupMembers.csv" -NoTypeInformation -Encoding UTF8