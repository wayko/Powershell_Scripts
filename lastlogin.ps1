$myarray = Import-Csv "c:\powershell\list.csv" 
$myarray | Export-CliXML c:\powershell\output.xml

$count = $myarray.Count
for($i = 0; $i -lt $count; $i++){
$ref = '<Obj RefId="' + $i + '">'
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace $ref ,'<Obj>'} | Set-Content C:\powershell\output.xml
$ref + " change is completed"
}
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<TN RefId="0">',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<TNRef RefId="0" />',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<MS>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<T>System.Management.Automation.PSCustomObject</T>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<T>System.Object</T>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</MS>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</TN>',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '<S N="email">',''} | Set-Content C:\powershell\output.xml
(Get-Content c:\powershell\output.xml) | ForEach-Object {$_ -replace '</S>',''} | Set-Content C:\powershell\output.xml

$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

connect-msolservice -credential $LiveCred


$xml = [xml]$users = Get-Content c:\powershell\output.xml
$finObj = $xml.objs.obj 

foreach($object in $finObj)
{Get-MsolUser -SearchString  $object | Export-Csv c:\powershell\allUsers.csv }