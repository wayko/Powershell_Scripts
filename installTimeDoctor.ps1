$TimeDocFile = "\\10.0.0.14\PublicShare\Timedoctor\sfproc-3.12.86-633de7247aa577e83d927389.msi" 
try 
{ 
start-process "c:\windows\system32\msiexec.exe" -ArgumentList "/i $TimeDocFile /qn" -wait 
write-host "Successful" 
Get-WmiObject win32_product | sort-object name|Where-Object {$_.Name -like "SFProc App"} | Format-Table Name, Version, identifyingnumber
} 
catch 
{ 
Write-Host "Error Occured" 
}