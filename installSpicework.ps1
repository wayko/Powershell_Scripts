$Spicework = "\\mz-vdc\Software\Spiceworks\SpiceworksAgentShell_Collection_Agent.msi" 
try { 
start-process "c:\windows\system32\msiexec.exe" -ArgumentList "/i $Spicework SITE_KEY=WNxbARwjHbWH4ZTbfvZr /qn /L*v c:\InstallSpicework.log" -wait 
write-host "Successful" 

} catch 
{ Write-Host "Error Occured" }
