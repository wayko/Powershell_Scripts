<#
$source = 'https://cc.us.absolute.com/api/agent-download/v1.0/downloads/169841ef-f457-4396-a046-e6a9c5f7100f'
$source3 = 'https://drive.google.com/uc?export=download&id=1c0RVhAo_-i7eCi0rAopR2-BwDpb6P9A6'
$source2 = 'https://signin.us.absolute.com/'
$destination = $($env:TEMP)+'\test.zip'
$user = 'fpretto@tomorrowsoffice.com'
$pass = 't62Pgks638*ImP5h'
$user = 'jortiz@tomorrowsoffice.com'
$pass = 'Aveeno00!'
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)
$headers = @{ Authorization = "Basic Zm9vOmJhcg==" } 
Invoke-WebRequest -Uri $source  -Credential $credential -Headers $headers -Method POST -OutFile $destination
Expand-Archive -Path $destination -DestinationPath $destination2 -Credential $credential
$msifile = $destination2 +'\AbsoluteAgent7.20.0.1-5001455.msi'
$source3 = 'https://drive.google.com/uc?export=download&id=1c0RVhAo_-i7eCi0rAopR2-BwDpb6P9A6'
$source3 =  “https://github.com/PowerShell/PowerShell/releases/download/v7.2.2/PowerShell-7.2.2-win-x64.msi“
$destination = $($env:TEMP) +'\AbsoluteAgent7.20.0.1-5001455.msi'
$destination2 = $($env:TEMP) + "\test.zip"
[system.Diagnostics.Process]::Start("firefox",$destination3)
Invoke-WebRequest -Uri $destination3 -OutFile $destination2
$downloadPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$downloadPath2 = $env:USERPROFILE +"\downloads"
#>

<# Declare Variables #>

$source3 = 'https://1drv.ms/u/s!AqoKz5JfFXu4c6BiBsDipdjPI4s?e=XCLawD'
$destination3 = "c:\users\public\downloads\test.html"

$downloadPath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders").PSObject.Properties["{374DE290-123F-4565-9164-39C4925E467B}"].Value 
$zipFile = $downloadPath + "\AbsoluteAgent7.20.0.1-50014551.zip"
$msifile = '"' + $downloadPath + "\AbsoluteAgent7.20.0.1-5001455.msi" + '"'


Invoke-WebRequest -Uri $source3 -OutFile $destination3 

try
{
write-host "Using Firefox"
start-process firefox $destination3 
}
catch
{
    try
    {
        write-host "Using Chrome"
        start-process chrome $destination3 
   }
    catch
    {
        try
        {
        write-host "Using ie"
        Start-Process iexplore $destination3
        }
        catch
        {
        try
        {
        write-host "Using edge"
        Start-Process msedge $destination3
        }
        catch
        {

        }
        }
    }
finally
{
 write-host "No browser found"
}
}



start-sleep -Seconds 60

<# Close Browser #>
try
{
write-host "Closing Firefox"
stop-process firefox $destination3 
}
catch
{
    try
    {
        write-host "Closing Chrome"
        stop-process chrome $destination3 
   }
    catch
    {
        try
        {
        write-host "Closing IExplorer"
        stop-Process iexplore $destination3
        }
        catch
        {
        try
        {
        write-host "Closing Edge"
        stop-Process msedge.exe $destination3
        }
        catch
        {

        }
        }
    }
finally
{
 write-host "No browser found"
}
}




Expand-Archive -Path $zipFile -DestinationPath $downloadPath -Force



Start-Process "C:\Windows\System32\msiexec.exe"  -ArgumentList "/i $msifile /norestart /quiet"  -Wait 