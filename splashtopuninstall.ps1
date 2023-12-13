$SplashGUID = Get-wmiobject Win32_Product -Filter "Name LIKE '%Splashtop Streamer%'" 


write-host "Killing Service"
Stop-Process -name SRServer -force
Stop-Process -name SRApp -force
Stop-Process -name SRAppPB -force
Stop-Process -name SRFeature -force
Stop-Process -name SRFeatMini -force
Stop-Process -name SRManager -force
Stop-Process -name SRAgent -force
Stop-Process -name SRChat -force
Stop-Process -name SRService -force
write-host "Service Killed"

Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($SplashGUID.IdentifyingNumber) /qn /noreboot" -Wait 

Get-ChildItem -Path 'HKLM:\SOFTWARE\Splashtop Inc.\Splashtop Remote Server"'




set varRegPath=HKLM^\Software
if defined ProgramFiles(x86) (set varRegPath=HKLM\Software\Wow6432Node)
reg delete "%varRegPath%\Splashtop Inc.\Splashtop Remote Server" /v PRODUCTID /f 2> nul



echo Uninstallation concluded; Please be aware the platform may re-install Splashtop onto your
echo device within a few minutes if the feature is still enabled in the Web Portal.
:eof