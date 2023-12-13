Get-MailboxStatistics -Server 'ExchSVR1' | Where {$_.ObjectClass -eq “Mailbox”} | 
Select-Object -Property @{label=”User”;expression={$_.DisplayName}},
@{label=”Total Messages”;expression={$_.ItemCount}},
@{label=”Total Size (MB)”;expression={$_.TotalItemSize.Value.ToMB()}}, LastLogonTime | 
Export-CSV "C:\MailBoxSize-Report.csv" -NoTypeInformation -Encoding UTF8