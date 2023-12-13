$computername = $env:COMPUTERNAME
$OS2 = Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

Try{
Install-Module -Name PSWindowsUpdate
write-host "Module installed successfully on $computername"
}
catch
{
  write-host "Error Occurred"
}


<# Windows 10 Start #>
if($OS2.WindowsVersion -eq "20H2" -or $OS2.WindowsVersion -eq "2004" -or $OS2.WindowsVersion -eq "21H1")
{
  try
{
 Get-WUInstall -KBArticleID "KB5004945" -IgnoreReboot -Download -Install
 write-host "Update installed successfully on $computername"
}
catch
{
write-host "Update failed on $computername"
}
}

if($OS2.WindowsVersion -eq "1909")
{
  try
{
 Get-WUInstall -KBArticleID "KB5004946" -IgnoreReboot
 write-host "Update installed successfully on $computername"
}
catch
{
write-host "Update failed on $computername"
}
}
<# Windows 10 Finish #>

<# Windows 2019 Server #>
if($OS2.WindowsVersion -eq "1809")
{
  try
{
 Get-WUInstall -KBArticleID 'KB5004947' -IgnoreUserInput -AcceptAll -Download -Install -IgnoreReboot -Verbose
 write-host "Update installed successfully on $computername"
}
catch
{
write-host "Update failed on $computername"
}
}
<# WIndows 2019 Server End #>



$WUHistory = Get-WUHistory | select-object ComputerName, Operationname, KB, Result |Sort-Object KB
[string[]]$KBList = @("KB5004945","KB5004946","KB5004947",",KB5004948""KB5004950","KB5004951","KB5004953","KB5004954","KB5004955","KB5004958","KB5004959")
Foreach($item in $WUHistory)
{
foreach($kbnumber in $kblist)
{

 if($item.KB -ne $kbnumber)
 {
   write-host "$kbnumber has not been found on $computername"
 }
 else
 {
  write-host "$kbnumber has been found on $computername and it $item.Result"
 }
 }
}
Get-WindowsUpdate