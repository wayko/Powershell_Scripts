$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
$date = Get-Date
$month = $date.Month
$day = $date.Day
$year = $date.Year
$fileLocation = "D:\backup 4-8-2014\powershell\office365NewStudents.csv" 
$xmlFiles = "D:\backup 4-8-2014\powershell\outputlist-" + $month + "-" + $day + "-" + $year + ".xml"
connect-msolservice -credential $LiveCred
Get-MsolAccountSku 
$myarray = Import-Csv  $fileLocation
$myarray | Export-CliXML $xmlFiles
Start-Sleep -s 20

(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<TN RefId="0">',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<TNRef RefId="0" />',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<MS>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<T>System.Management.Automation.PSCustomObject</T>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<T>CSV:Selected.Microsoft.ActiveDirectory.Management.ADUser</T>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '</MS>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '</TN>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<S N="UserPrincipalName">','<S>'} | Set-Content $xmlFiles

$options = "livetcicollege:OFFICESUBSCRIPTION_STUDENT"
$LicOptions = New-MsolLicenseOptions -AccountSkuId $options

[xml]$xml = Get-Content $xmlFiles 
$findObj = $xml.objs. 'Obj'  | ForEach-Object {$_.CreateNavigator().SelectChildren('Element').Value}

 foreach($object in $findObj){
 
  ForEach-Object {Set-MsolUserLicense -User $object -AddLicenses $options}
 }
 Get-MsolAccountSku