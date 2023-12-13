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

$WUHistory = Get-WUHistory | select-object ComputerName, Operationname, KB, Result | sort-object KB

Foreach($item in $WUHistory)
{

 if($item.KB -ne "KB5004947")
 {
   write-host "KB5004947 has not been found on $computername" 
 }
 else
 {
  write-host "KB5004947 has been found on $computername and it result is"$item.Result
  break
 }
 }

 Get-WindowsUpdate
