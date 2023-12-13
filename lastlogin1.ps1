$myarray = Import-Csv "c:\powershell\list.csv"
$myarray | Export-CliXML c:\powershell\output.xml
Start-Sleep -s 20

(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<TN RefId="0">',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<TNRef RefId="0" />',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<MS>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<T>System.Management.Automation.PSCustomObject</T>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<T>System.Object</T>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</MS>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</TN>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<S N="gbake226678">','<S>'} | Set-Content C:\powershell\output.xml

Start-Sleep -s 20

$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

connect-msolservice -credential $LiveCred


Start-Sleep -s 20




$xml = [xml]${c:\powershell\output.xml}
$finObj = $xml.objs. 'Obj'  | ForEach-Object {$_.CreateNavigator().SelectChildren('Element').Value}

foreach($object in $finObj){  Get-MsolUser -SearchString $object | fl | Out-File  c:\powershell\output.txt -append }



get-msoluser -All  | Export-Csv c:\powershell\LicensedUsers.csv