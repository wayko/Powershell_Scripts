$computername = $env:COMPUTERNAME
$PSVersion = get-host | Select-Object version 
$fileLocattion = "c:\temp\Error.txt"<# Change This location to a shared file on the network #>

If($PSVersion.Version.ToString()-le 4.0){
$OS2 =  @{
WindowsProductName = (Get-WmiObject Win32_OperatingSystem).caption
WindowsBuildNumber = (Get-WmiObject Win32_OperatingSystem).buildNumber
}
  }
  else
  {
$OS2 = Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Try{
Install-Module -Name PSWindowsUpdate 
write-host "Module installed successfully on $computername"
}
catch
{
  write-host "Error Occurred"
  "Error Occurred" | out-file $fileLocation -append
}
}

function getOSKB($OSVersion, $KBId)
{
	try
	{
		Get-WUInstall -KBArticleID $KBId -IgnoreReboot -Download -Install -IgnoreUserInput -Verbose
		write-host "Update installed successfully on $computername"
	}
	catch
	{
		write-host "Update failed on $computername"
		 "Update failed on $computername" | out-file $fileLocation -append
	}

$WUHistory = Get-WUHistory | select-object ComputerName, Operationname, KB, Result | sort-object KB

Foreach($item in $WUHistory)
{
 if($item.KB -ne $KBId)
 {
   write-host "$KBId has not been found on $computername" 
 }
 else
 {
  write-host "$KBId has been found on $computername and it result is"$item.Result
  break
 }
 }
 Get-WindowsUpdate	
}

<# Windows 7 SP1 #>
if($OS2.WindowsProductName -like "*Windows 7*" -and $OS2.WindowsBuildNumber -eq "7601")
{
  try
{
 #Source folder msu file must be downloaded ahead of time
$SourceFolder = "c:\windows\temp\KB5004953win7.msu"
Test-Path -path $SourceFolder
Start-Process -FilePath "wusa.exe" -ArgumentList "$SourceFolder /quiet /norestart" -Wait  
write-host "Update installed on $computername"
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# WIndows 7 SP1 End #>

<# Windows 8.1 #>
if($OS2.WindowsProductName -like "*Windows 8*")
{
  try
{
 #Source folder msu file must be downloaded ahead of time
$SourceFolder = "c:\temp\KB5004954.msu"
Test-Path -path $SourceFolder
write-host "Updating $computername with KB5004954"
Start-Process -FilePath "wusa.exe" -ArgumentList "$SourceFolder /quiet /norestart" -Wait  
write-host "Update installed on $computername"
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# WIndows 8.1 End #>


<# Windows 10 Start #>
if($OS2.WindowsVersion -eq "20H2" -or $OS2.WindowsVersion -eq "2004" -or $OS2.WindowsVersion -eq "21H1" -or $OS2.WindowsVersion -eq "2009")
{

  try
{
 getOSKB $OS2.WindowsVersion "KB5004945"
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
 getOSKB $OS2.WindowsVersion "KB5004946" 
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# Windows 10 Finish #>

<# Windows 2012 Server Standard #>
if($OS2.WindowsProductName -like "*Windows Server 2012 Standard*")
{
  try
{
 #Source folder msu file must be downloaded ahead of time
$SourceFolder = "c:\temp\KB5004956.msu"
Test-Path -path $SourceFolder
Start-Process -FilePath "wusa.exe" -ArgumentList "$SourceFolder /quiet /norestart" -Wait  
write-host "Update installed on $computername"
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# WIndows 2012 Server Standard End #>

<# Windows 2012 Server R2 #>
if($OS2.WindowsProductName -like "*Windows Server 2012 R2*")
{
  try
{
 #Source folder msu file must be downloaded ahead of time
$SourceFolder = "c:\temp\KB5004954.msu"
Test-Path -path $SourceFolder
Start-Process -FilePath "wusa.exe" -ArgumentList "$SourceFolder /quiet /norestart" -Wait  
write-host "Update installed on $computername"
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# WIndows 2012 Server R2 End #>



<# Windows 2016 Server #>
if($OS2.WindowsProductName -like "Windows Server 2016*")
{
  try
{
 getOSKB $OS2.WindowsProductName 'KB5004948' 
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# WIndows 2016 Server End #>


<# Windows 2019 Server #>
if($OS2.WindowsVersion -eq "1809")
{
  try
{
 getOSKB $OS2.WindowsVersion 'KB5004947' 
}
catch
{
write-host "Update failed on $computername"
"Update failed on $computername" | out-file $fileLocation -append
}
}
<# WIndows 2019 Server End #>

<# Printer Registry Entry #>
$regkey = "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" 
if(!(Get-ItemProperty $regkey))
{
write-host "Adding new registry entry" 
Push-Location
Set-Location HKLM:
Test-Path .\Software\Policies\Microsoft\"Windows NT"\Printers\PointAndPrint
New-Item -Path .\Software\Policies\Microsoft\"Windows NT" -Name Printers
New-Item -Path .\Software\Policies\Microsoft\"Windows NT\Printers" -Name PointAndPrint
Pop-Location
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnInstall" -Value 0
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnUpdate" -Value 0
write-host "Registry entry added" 
}
else
{
	write-host "Updating registry entry" 
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnInstall" -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnUpdate" -Value 0
	write-host "Registry entry updated" 
 }
<# Printer Registry Entry End #>