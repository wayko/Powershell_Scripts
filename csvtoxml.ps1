$fileLocation = "F:\CourseCatalog.csv" 
$xmlFiles = "F:\CourseCatalog.xml"
$myarray = Import-Csv  $fileLocation

write-host "CSV File Imported" -ForegroundColor Cyan

$myarray |% {'<?xml version="1.0" standalone="true"?>'}{'<AF_Catalog>'} {$_.psobject.properties |% {'  <AF_Course>'} {"    <$($_.name)>$($_.value)<\$($_.name)>"} {'  <\AF_Course>'} } {'<\AF_Catalog>'} | Out-File $xmlFiles
write-host "XML File Created" -ForegroundColor Red