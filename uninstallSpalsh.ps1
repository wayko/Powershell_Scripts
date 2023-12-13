#!/bin/sh
@echo off
echo ==============================
echo MULTI-PLATFORM SCRIPT: Splashtop Uninstaller
echo Please scrutinise StdErr output - some errors are expected.
echo ==============================
goto WindowsScript



# splashtop uninstaller multi-platform script :: build 10, may 2022



echo "Please disregard above lines; they are side-effects of the dual-platform script functionality." >&2
echo "==============================" >&2
echo You are running a UNIX-based system.
##############################################
streamerRunning=$(ps aux | grep 'Splashtop https://linkprotect.cudasvc.com/url?a=https%3a%2f%2fStreamer.app&c=E,1,C8w4xNjOI8L61mg8vU2WlUvRi17uDFNHLeH_nQsgXIFwQSVc9FgtGgAWPPFyAacwwBF_8ZfRvmPbVnZpApdQTksAFnx9yZzxh_a_JZW5pR03oQ,,&typo=1' | grep -v grep | wc -l)
until [ $streamerRunning -eq 0 ]
do
   streamerPID=$(ps aux | grep 'Splashtop https://linkprotect.cudasvc.com/url?a=https%3a%2f%2fStreamer.app&c=E,1,CYtCqMjfpP8rB0n74NPBApDwQZUzxI-sqIsvxq3QdiFYTmhHeb7lQkPaKKlwl-XtSQC0OlhY09U_Hv-eR72hBovvpkFmbZ5cPxi-stHy&typo=1' | grep -v grep | awk '{print $2}' | head -1)
   kill $streamerPID
   streamerRunning=$(ps aux | grep 'Splashtop https://linkprotect.cudasvc.com/url?a=https%3a%2f%2fStreamer.app&c=E,1,L6FQdOFWGmHCAjV5N1i2U9fnYVml_SzhrmRQ-tMwS4yoqfxCoahe5nTFMXm7cnwakaZU1PdXKUD-O4AcR6go1YMOadOlHx1ba3cgzH2elEhE2qQ1ASU,&typo=1' | grep -v grep | wc -l)
done
##############################################
sleep 15
echo "=============================="
echo "Output from Splashtop-authored macOS uninstaller script:"
sh https://linkprotect.cudasvc.com/url?a=https%3a%2f%2fUninstall2205.sh&c=E,1,cmfb8vLr-6cgOl0x7FexKm5ZUw-7XaKuy8m4Bj4GCqzvVx_RALDOUI6FpWDOUorKKuzVImV5S_7Og_gl5QLaqAk2Bna3Dz9_mS2vcRiPnqsQfg,,&typo=1
echo "=============================="
echo 'Uninstallation concluded; Please be aware the platform may re-install Splashtop onto your'
echo 'device within a few minutes if the feature is still enabled in the Web Portal.'
echo "==============================" >&2
exit
:WindowsScript

echo Please disregard above lines; they are side-effects of the dual-platform script functionality. 1>&2
echo ============================== 1>&2
echo You are running Windows.
for /f "usebackq tokens=1 delims=" %%i in (`wmic product where "Name like '%%Splashtop Streamer%%'" get IdentifyingNumber ^| findstr /r /v "^$"`) do set StopGUID=%%i
echo "Found SplashTop"
echo "Killing Services"
taskkill.exe /F /IM SRServer.exe /T
taskkill.exe /F /IM SRApp.exe /T
taskkill.exe /F /IM SRAppPB.exe /T
taskkill.exe /F /IM SRFeature.exe /T
taskkill.exe /F /IM SRFeatMini.exe /T
taskkill.exe /F /IM SRManager.exe /T
taskkill.exe /F /IM SRAgent.exe /T
taskkill.exe /F /IM SRChat.exe /T
echo "Service task killed"
echo "Uninstalling Splashtop"
start /wait MsiExec.exe /X %StopGUID% /quiet /Li "c:\users\administrator\desktop\spalshlog.log" /norestart



set varRegPath=HKLM^\Software
if defined ProgramFiles(x86) (set varRegPath=HKLM\Software\Wow6432Node)
reg delete "%varRegPath%\Splashtop Inc.\Splashtop Remote Server" /v PRODUCTID /f 2> nul



echo Uninstallation concluded; Please be aware the platform may re-install Splashtop onto your
echo device within a few minutes if the feature is still enabled in the Web Portal.
:eof