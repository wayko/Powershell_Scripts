New-Item c:\temp\config.xml -ItemType File

Set-Content c:\temp\config.xml '<Configuration Product="PROPLUS">
<Display Level="none" CompletionNotice="no" SuppressModal="yes" AcceptEula="yes" />
<Setting Id="SETUP_REBOOT" Value="Never" />
</Configuration>'


New-item c:\temp\uninstalloffice.bat -ItemType File
set-content c:\temp\uninstalloffice.bat 'ECHO OFF
IF EXIST "%CommonProgramFiles%\Microsoft Shared\OFFICE15\Office Setup Controller\setup.exe" (
  "%CommonProgramFiles%\Microsoft Shared\OFFICE15\Office Setup Controller\setup.exe"/uninstall PROPLUS /dll OSETUP.DLL /config "c:\temp\config.xml"
) ELSE (
  echo "Office 2013 Not Found"
)'


cmd.exe /c 'C:\temp\uninstalloffice.bat'