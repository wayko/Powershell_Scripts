$userfolder = Get-ChildItem -path c:\users -Directory

foreach ($user in $userfolder)
{
    $appdatafolder = "c:\users\$user\appdata\roaming\Microsoft\Teams\Backgrounds\Uploads"
    $appdatafolder
    Remove-Item -Path $appdatafolder\*.* -Force -ErrorAction SilentlyContinue

}