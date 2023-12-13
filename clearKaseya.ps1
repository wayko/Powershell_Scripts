Get-ChildItem C:\Kworking -Recurse | ForEach{ Remove-Item $_.FullName -Force -Recurse }

Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\RMM -Force -Verbose


