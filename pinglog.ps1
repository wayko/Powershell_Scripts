Start-Transcript -path C:/Script/PingLog.txt -Append
Ping.exe -t spiceworks.com | ForEach {"{0} - {1}" -f (Get-Date),$_}