Get-MailboxStatistics -Server 'ExchSVR1' | Where {$_.ObjectClass -eq Mailboxù} | 
Select-Object -Property @{label=ùUserù;expression={$_.DisplayName}},
@{label=ùTotal Messagesù;expression={$_.ItemCount}},
@{label=ùTotal Size (MB)ù;expression={$_.TotalItemSize.Value.ToMB()}}, LastLogonTime | 
Export-CSV "C:\MailBoxSize-Report.csv" -NoTypeInformation -Encoding UTF8