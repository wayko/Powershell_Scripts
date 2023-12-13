$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
write-host "Connection Setup" -ForegroundColor Cyan

$date = Get-Date
$month = $date.Month
$day = $date.Day
$year = $date.Year
$fileLocation = "F:\backup 4-8-2014\powershell\nolicense-" + $month + "-" + $day + "-" + $year + ".csv" 
$xmlFiles = "F:\backup 4-8-2014\powershell\nolicensexml-" + $month + "-" + $day + "-" + $year + ".xml"

write-host "Files Made" -ForegroundColor Cyan

connect-msolservice -credential $LiveCred
Get-MsolDomain 

write-host "Connection Made" -ForegroundColor Cyan

 Get-MsolUser -All  | Where-Object {$_.isLicensed -ne "TRUE"} | Select UserPrincipalName | export-csv  $fileLocation

 write-host "Export Complete" -ForegroundColor Cyan
 
$myarray = Import-Csv  $fileLocation
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

write-host "XML File Made" -ForegroundColor Cyan

$options = "livetcicollege:STANDARDWOFFPACK_IW_STUDENT"

[xml]$xml = Get-Content $xmlFiles 
$findObj = $xml.objs.'Obj'  | ForEach-Object {$_.CreateNavigator().SelectChildren('Element').Value}


  
  foreach($object in $findObj){
  ForEach-Object { write-host "[INFO] Processing $object" -ForegroundColor Yellow
   try
 {
 
 ForEach-Object { Set-MsolUser -UserPrincipalName $object -UsageLocation "US" }
 write-host "[INFO] Processed $object" -ForegroundColor Green 
 }
  catch
 {
 write-host "[Warning] Error on $object" -ForegroundColor Red 
 }
 }
 }
 
 
 
 foreach($object in $findObj){
 ForEach-Object { write-host "[INFO] Processing $object" -ForegroundColor DarkYellow
 try
 {
  ForEach-Object {Set-MsolUserLicense -UserPrincipalName $object -AddLicenses $options }
  write-host "[INFO] Processed $object" -ForegroundColor DarkGray
 }
 catch
 {
 
 write-host "[Warning] Error on $object" -ForegroundColor Magenta
 }
 }
 }
 write-host $findObj.Count "Students Proccessed" -ForegroundColor Cyan


