Get-ChildItem C:\Kworking -Recurse | ForEach{ Remove-Item $_.FullName -Force -Recurse }
$Kworkingfolder = "C:\Kworking"
Remove-Item $Kworkingfolder -Force -Recurse

Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\RMM -Force -Verbose

Unregister-ScheduledTask -TaskName RMM_MaintV2 -Confirm:$false
Unregister-ScheduledTask -TaskName RMM_PRNM -Confirm:$false
