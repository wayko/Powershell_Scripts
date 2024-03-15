if ((Get-WmiObject -Class Win32_Product -Filter "name like 'VMware Enhanced Authentication Plug-in'") -eq $null)
{
    Write-Host "Not Vulnerable. VMware Enhanced Authentication Plug-in not installed." -ForegroundColor Green 
}
else
{
    Write-Host "Vulnerable. VMware Enhanced Authentication Plug-in was found to be installed on the system." -ForegroundColor Yellow 
    (Get-WmiObject -Class Win32_Product -filter  "name like 'VMware Enhanced Authentication Plug-in'").Uninstall()
    Stop-Service -Name "CipMsgProxyService"
    Set-Service -Name "CipMsgProxyService" -StartupType "Disabled"
}

if ((Get-WmiObject -Class Win32_Product -Filter "name like 'VMware Plug-in Service'") -eq $null)
{
    Write-Host "Not Vulnerable. VMware Plug-in Service not installed." -ForegroundColor Green 
}
else
{
    Write-Host "Vulnerable. VMware Plug-in Service was found to be installed on the system." -ForegroundColor Yellow  
    (Get-WmiObject -Class Win32_Product -filter  "name like 'VMware Plug-in Service'").Uninstall()
    Stop-Service -Name "CipMsgProxyService"
    Set-Service -Name "CipMsgProxyService" -StartupType "Disabled"
}


$vmwareFolder = "C:\Program Files (x86)\VMware\Enhanced Authentication Plug-in 6.7\"
if(Test-path $vmwareFolder)
{
    write-host "Vulnerable. C:\Program Files (x86)\VMware\Enhanced Authentication Plug-in 6.7\ exist on machine." -ForegroundColor Yellow
}
else
{
     write-host "Not Vulnerable. C:\Program Files (x86)\VMware\Enhanced Authentication Plug-in 6.7\ does not exist on machine." -ForegroundColor Green
}

$service = Get-Service -Name CipMsgProxyService -ErrorAction SilentlyContinue

if($service -ne $null)
{
    write-host "Vulnerable. Service exist" -ForegroundColor Yellow
    Stop-Service -Name "CipMsgProxyService"
    Set-Service -Name "CipMsgProxyService" -StartupType "Disabled"
}
else
{
    write-host "Not Vulnerable. Service does not exist" -ForegroundColor Green
}