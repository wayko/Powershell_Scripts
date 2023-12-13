$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
$date = Get-Date
$month = $date.Month
$day = $date.Day
$year = $date.Year
$currentFile = "D:\backup 4-8-2014\powershell\CurrentList.csv" 
$xmlFiles = "D:\backup 4-8-2014\powershell\nolicensexml-" + $month + "-" + $day + "-" + $year + ".xml"
connect-msolservice -credential $LiveCred

 
$myarray = Import-Csv $currentFile
$myarray | Export-CliXML $xmlFiles
Start-Sleep -s 20

(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<TN RefId="0">',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<TNRef RefId="0" />',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<MS>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<T>System.Management.Automation.PSCustomObject</T>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<T>CSV:Selected.Microsoft.Online.Administration.User</T>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '</MS>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '</TN>',''} | Set-Content $xmlFiles
(Get-Content $xmlFiles) | ForEach-Object {$_ -replace '<S N="UserPrincipalName">','<S>'} | Set-Content $xmlFiles

$options = "subscription"

[xml]$xml = Get-Content $xmlFiles 
$findObj = $xml.objs.'Obj'  | ForEach-Object {$_.CreateNavigator().SelectChildren('Element').Value}

 foreach($object in $findObj){
  ForEach-Object { write-host "[INFO] Processing $object" -ForegroundColor Yellow
  try
 {
  Set-MsolUserLicense -UserPrincipalName $object -AddLicenses $options 
  write-host "[INFO] Processed $object" -ForegroundColor Green 
 }
 catch
 {
 write-host "[Warning] Error on $object" -ForegroundColor Red 
 }
 }
  }

  Get-MsolAccountSku