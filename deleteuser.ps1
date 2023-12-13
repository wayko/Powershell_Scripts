$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

connect-msolservice -credential $LiveCred
Get-MSOLUser -HasErrorsOnly |Select UserPrincipalName | export-csv  "c:\powershell\errors.csv" 
$myarray = Import-Csv "c:\powershell\errors.csv"
$myarray | Export-CliXML c:\powershell\errorlist.xml
Start-Sleep -s 20

(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '<TN RefId="0">',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '<TNRef RefId="0" />',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '<MS>',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '<T>System.Management.Automation.PSCustomObject</T>',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '<T>CSV:Selected.Microsoft.Online.Administration.User</T>',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '</MS>',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '</TN>',''} | Set-Content C:\powershell\errorlist.xml
(Get-Content c:\powershell\errorlist.xml) | ForEach-Object {$_ -replace '<S N="UserPrincipalName">','<S>'} | Set-Content C:\powershell\errorlist.xml
Start-Sleep -s 20

$xml = [xml]${c:\powershell\errorlist.xml}
$finObj = $xml.objs. 'Obj'  | ForEach-Object {$_.CreateNavigator().SelectChildren('Element').Value}

foreach($object in $finObj){
ForEach-Object { remove-msoluser -UserPrincipalName $object -Force }
ForEach-Object { remove-msoluser -userprincipalname $object -removefromrecyclebin }
}