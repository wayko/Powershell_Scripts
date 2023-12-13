$myarray = Import-Csv "c:\powershell\list.csv"
$myarray | Export-CliXML c:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<TN RefId="0">',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<TNRef RefId="0" />',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<MS>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<T>System.Management.Automation.PSCustomObject</T>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<T>System.Object</T>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</MS>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</TN>',''} | Set-Content C:\powershell\output.xml

      
