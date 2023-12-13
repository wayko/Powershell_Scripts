<# 
.Synopsis 
Duo for Windows Logon Support Script. This script creates a zip file with log files and the sanitized Duo configuration.
.Description
This command has the following flags:
-duodebug :defaults off; $true enabled debug in registry; $false disables debug in registry
-out :sets the preferred log path; defaults to desktop if not set
-eventlogs : Will export application and/or security logs: options: all, application, security
-days: Setting this will grab logs from the last X days, for both duo native logs and event logs
-tls: Export Client TLS settings from registry
.Example
PS C:\>Winlogon-Diag.ps1 -duodebug $true 
PS C:\>Winlogon-Diag.ps1 -out C:\testing -eventlogs security -days 2
.LINK
https://duo.com/support
#>

#=================================================================================
# Duo for Windows Logon Support Script
# version: 0.7
# date: 05/10/23
# Release notes: Updated support script to check and enable TLS 1.2 if not enabled
#=================================================================================



param (
  [string]$duodebug = $null,
  [string]$out = (Get-Location).path + "\",
  [switch]$help,
  [switch]$tls,
  [Parameter(ParameterSetName='Extra',Mandatory=$false)][string]$eventlogs = $false,
  [Parameter(ParameterSetName='Extra',Mandatory=$false)][string]$days = $false
    )
#all the variables 
$credfilter = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Provider Filters"
$credprov = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers"
$localreg = "HKLM:\SOFTWARE\Duo Security\DuoCredProv"
$GPOReg = "HKLM:\SOFTWARE\Policies\Duo Security\DuoCredProv"
$uninstallkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
$DuoLog = "$env:ProgramData\Duo Security\duo.log"
$logpath = ($out).TrimEnd('\')
$newlogfolder = new-item -path "$logpath\DuoSupport_$(get-date -f yyyy-MM-dd-hh-mm-ss)" -ItemType directory
$LogFile = New-Item -path "$newlogfolder\DuoSupport.log" -ItemType File

#logging function
function LogMessage{
  [cmdletbinding()]
  param([string]$Message)
    ((Get-Date).ToString() + " - " + $Message) >> $LogFile;
 }
#check if user context is administrative
function Get-adminstatus {
  [cmdletbinding()]
  param ()
  try {
      $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
      $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
      return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
  } catch {
      throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
  }
 }
 #Check if TLS 1.2 is enabled and if not, ensure it is enabled
Function Enable-Tls12{
    [cmdletbinding()]
    param ()
    try {
        Write-Output "Checking if TLS 1.2 is enabled..."
        $currentProtocol = [Net.ServicePointManager]::SecurityProtocol
        Write-Output "Current TLS version(s): $currentProtocol"

        if (-not ($currentProtocol -band [Net.SecurityProtocolType]::Tls12)) {
            Write-Output "TLS 1.2 is not enabled. Enabling now..."
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $enabledTls = [Net.ServicePointManager]::SecurityProtocol
            Write-Output "TLS 1.2 has successfully been enabled. New TLS version: $enabledTls"
        }
    }
    catch {
        Write-Error "An error occured while enabling TLS 1.2: $($_.Exception.Message)"
    }   
}
#Check the version of duo installed by parsing the Registry Uninstall Keys
Function Get-DuoVersion{
  [cmdletbinding()]
  param ()
  Try{
    Get-ChildItem $uninstallkey -Recurse -ErrorAction Stop | ForEach-Object {
    $CurrentKey = (Get-ItemProperty -Path $_.PsPath)
    if ($CurrentKey -match "Duo Authentication for Windows Logon") {
      $DV = write-output "$($CurrentKey.DisplayName) $($CurrentKey.DisplayVersion)"
      }
  }
  If ($DV -eq $null){
    Write-Output "Duo for Windows Logon (Microsoft RDP) not installed."
    }
  Else {
    Write-output $DV
  }
  }
  catch{
    Write-Output "Cannot determine if Duo for Windows Logon (Microsoft RDP) is installed."
  }
}
#Exporting existing credential providers to another file in the running directory
Function Get-CredProv{
[cmdletbinding()]  
param ()
  Get-ChildItem -Path $credprov | Format-Table -AutoSize | Out-File $newlogfolder\credprov.txt 
  Get-ChildItem -Path $credfilter | Format-Table -AutoSize | Out-File $newlogfolder\credprov.txt -Append
}
#Allows for enabling and disabling the debug registry flag
Function Enable-Debug{
[cmdletbinding()]  
param ()

  try{
  If ($duodebug -eq $true){
    Set-ItemProperty -Path $localreg -Name Debug -Value 1 -type DWORD
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "DarkGreen"
    Write-Output "Log Debugging has been enabled"
    $host.ui.RawUI.ForegroundColor = $t
  }
  elseif($duodebug -eq $false){
    Set-ItemProperty -Path $localreg -Name Debug -Value 0 -type DWORD
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "Yellow"
    Write-Output "Log Debugging has been disabled"
    $host.ui.RawUI.ForegroundColor = $t
  }
  }
  Catch [System.Management.Automation.PSArgumentException]{
  "Registry Key Property missing"
  }
  Catch [System.Management.Automation.ItemNotFoundException]{
  "Registry Key itself is missing"
  }
  Finally {
  $ErrorActionPreference = "Continue"
  }
}

# Export networking information for trusted sessions
function Get-Network {
  [cmdletbinding()]
  param ()
  Write-Output "Default Route:" | Out-File $newlogfolder\NetworkSettings.txt
  $DefaultRoute =  Get-NetRoute -DestinationPrefix "0.0.0.0/0"
  $DefaultRoute | Format-List | Out-File $newlogfolder\NetworkSettings.txt -Append
  Get-NetNeighbor -IPAddress $DefaultRoute.NextHop | Format-List | Out-File $newlogfolder\NetworkSettings.txt -Append
  
  Write-Output "Default Adapter:" | Out-File $newlogfolder\NetworkSettings.txt -Append
  Get-NetAdapter -IfIndex $DefaultRoute.ifIndex | Format-List | Out-File $newlogfolder\NetworkSettings.txt -Append
  
  Write-Output "Wireless Settings:" | Out-File $newlogfolder\NetworkSettings.txt -Append
  netsh wlan show interfaces | Format-List | Out-File $newlogfolder\NetworkSettings.txt -Append 
}

#Export duo logs, default to whole log but when used with $days flag it will limit time range
function Get-DuoLog {
  [cmdletbinding()]
  param ()
  if ($days -eq $false){
    Copy-Item $DuoLog -Destination $newlogfolder
  }
  else{
    $backdate = (get-date).AddDays(-$days).ToString("MM/dd/yy")
    Get-Content $DuoLog | % { if ($_ -ge $backdate) {Write-Output $_ | Out-file $newlogfolder\Duo.Log -force -Append }}
 }
}

#Export security logs must be used with $days flag to limit time range
function export-securitylog{
  [cmdletbinding()]  
  param ()
  if($days -ne $false){
    $old = (get-date).AddDays(-$days)
    $miltime = (New-TimeSpan -Start $old -End (Get-Date)).totalmilliseconds
    wevtutil epl security /q:"*[System[TimeCreated[timediff(@SystemTime) <= $miltime]]]" "$newlogfolder\security.evtx" /overwrite:true
  }
  else{
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "Red"
    Write-Output "Please re-run script with -days <value> set"
    $host.ui.RawUI.ForegroundColor = $t
  }
}

#Export application logs must be used with $days flag to limit time range
function export-applicationlog{
  [cmdletbinding()]
  param ()  
  if($days -ne $false){
    $old = (get-date).AddDays(-$days)
    $miltime = (New-TimeSpan -Start $old -End (Get-Date)).totalmilliseconds
    wevtutil epl application /q:"*[System[TimeCreated[timediff(@SystemTime) <= $miltime]]]" "$newlogfolder\application.evtx" /overwrite:true
    }
    else{
      $t = $host.ui.RawUI.ForegroundColor
      $host.ui.RawUI.ForegroundColor = "Red"
      Write-Output "Please re-run script with -days <value> set"
      $host.ui.RawUI.ForegroundColor = $t
    }
}
$localreg = "HKLM:\SOFTWARE\Duo Security\DuoCredProv"

Function get-duocheck{

$RegProperty = (Get-ItemProperty $localreg -name Host).Host 
$RestError = $null
try
    {
    $IWR = Invoke-WebRequest -Uri https://$RegProperty/auth/v2/ping 
    Write-Output "Connectivity Response to Duo:" $IWR.StatusDescription
    }
catch
    {
    $RestError = $_
  Write-Output "Connectivity Response to Duo failed due to:" $RestError.Exception 
      }
}

if ($help){
  get-help .\Winlogon-Diag.ps1
  EXIT
}

# Check Admin status
$admin = Get-adminstatus

if ((Test-Path $localreg) -eq $false){
  $t = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = "Red"
  $installstatus = "Duo for Windows Logon (Microsoft RDP) not installed."
  Write-Output $installstatus
  $host.ui.RawUI.ForegroundColor = $t
  Remove-Item $newlogfolder -recurse -force
  }
  elseif($admin -eq $false){
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "Red"
    $adminstatus = "Please re-run script as an administrator"
    Write-Output $adminstatus
    $host.ui.RawUI.ForegroundColor = $t
    Remove-Item $newlogfolder -recurse -force
    }
  else{
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "Green"
    $adminstatus = "Script has been run with administrative access"
    Write-Output $adminstatus
    $host.ui.RawUI.ForegroundColor = $t
  # Check Debug status  
if ($duodebug -eq $true -or $duodebug -eq $false){
        Enable-Debug  
        exit
      }
    
if ((Get-ItemProperty -Path $localreg).debug -eq 0){
  $initaldebug = "Debug Off"
  }
if ((Get-ItemProperty -Path $localreg).debug -eq 1){
  $initaldebug = "Debug On"
  }
#Check if 2016+/Win10+
$majorver = ([System.Environment]::OSVersion.Version).major
if ($majorver -eq 10){
 $win10 = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion').releaseID
 $osInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, ServicePackMajorVersion, OSArchitecture, CSName, WindowsDirectory

}
else {
  $win10 = $null
  $osInfo = [System.Environment]::OSVersion
}

#Setting TLS Version to 1.2
Enable-Tls12

Get-DuoLog
#export app logs
if($days -ne $false -and $eventlogs -eq "application" -or $eventlogs -eq "all" )
{export-applicationlog}
#export sec logs
if($days -ne $false -and $eventlogs -eq "security" -or $eventlogs -eq "all" )
{export-securitylog}

#Get variables for logging
$lastlogonprov = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI').LastLoggedOnProvider
$lastloggedonduo =  if ($lastlogonprov -eq '{44E2ED41-48C7-4712-A3C3-250C5E6D5D84}'){
                        Write-Output "Yes"
                    } else {
                      Write-Output "No"
                    }

$SSLduocheck = get-duocheck
$credprovs = Get-CredProv
$network = Get-Network
$duoversion = Get-DuoVersion 
$gpostatus = Test-Path $GPOReg
$proxies = If ((Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer -eq $Null){
    Write-Output "No Browser Proxy"
    }else{
    Write-Output (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer
    }
$output = netsh winhttp show proxy
$null, $proxy = $output -like '*proxy server(s)*' -split ' +: +', 2
$sysprox = if ($proxy) {$proxy} else {'No System Proxy'}
if ($majorver -gt 8){
$bitlockerstatus = Try {(Get-BitLockerVolume $env:systemdrive).volumestatus} catch {Write-Output "Not Detected"}
$avinstalled = Try{(Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct).displayname}  catch {Write-Output "Not Detected"}
$tpmstatus = Try{(get-tpm).tpmpresent} catch {Write-Output "Not Detected"}
}
if ($majorver -lt 7){
$oldtpm = Try {(Get-WmiObject -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm).isactivated_initialvalue } catch {Write-Output "Not Detected"}
$oldtime = Try{(Get-WmiObject -Class win32_timezone).caption} catch {Write-Output "Not Detected"}
$query = 'Select ProtectionStatus from Win32_EncryptableVolume WHERE DriveLetter = ''$env:systemdrive:'''
$query = $ExecutionContext.InvokeCommand.ExpandString($query)
$obl = manage-bde.exe -status $env:systemdrive 
$oldbitlocker = try {Write-Output $obl | findstr /i "Protection Status"} catch {Write-Output "Not Detected"}
$oldavwmiQuery = "SELECT * FROM AntiVirusProduct" 
$oldavinstalled = try {Get-WmiObject -Namespace "root\SecurityCenter2" -Query $oldavwmiQuery} catch {Write-Output "Not Detected"}
}
#Get all the things to message out
LogMessage -Message ==============================================================================
LogMessage -Message "$SSLduocheck"
LogMessage -Message ==============================================================================
LogMessage -Message "Installed Version: $duoversion"
LogMessage -Message "GPO deployed: $gpostatus"
LogMessage -Message ==============================================================================
LogMessage -Message $adminstatus
LogMessage -Message "Status: $initaldebug"
LogMessage -Message ==============================================================================
LogMessage -Message "Host Information"
LogMessage -Message "Hostname: $env:computername"
LogMessage -Message "Username: $env:UserName"
LogMessage -Message "Domain: $env:UserDomain"
LogMessage -Message "System Proxy: $sysprox"
LogMessage -Message "Browser Proxy: $proxies"
#Win 7/2008 logging
if ($majorver -lt 8){
    LogMessage -Message "OS Version: $(($osinfo).VersionString)"
    LogMessage -Message "OS Build: $(($osinfo).version)"
    LogMessage -Message "OS Bit: $(($osinfo).Platform)"
    LogMessage -Message "Bitlocker Status: $oldbitlocker"
    LogMessage -Message "AV Product: $(($oldavinstalled).displayName)"
    LogMessage -Message "TPM Available: $oldtpm"
    LogMessage -Message "Timezone: $oldtime"    
    } 
#Win8/2012 and higher    
if ($majorver -ge 8){
LogMessage -Message "OS Version: $(($osinfo).caption), $win10"
LogMessage -Message "OS Build: $(($osinfo).version)"
LogMessage -Message "OS Bit: $(($osinfo).OSArchitecture)"
LogMessage -Message "Bitlocker Status: $bitlockerstatus"
LogMessage -Message "AV Product: $avinstalled"
LogMessage -Message "TPM Available: $tpmstatus"
LogMessage -Message "Timezone: $((get-timezone).id)"    
} 
LogMessage -Message "Last Logged On Provider GUID: $lastlogonprov"
LogMessage -Message "Was Last Logon Provider Duo: $lastloggedonduo"
LogMessage -Message ==============================================================================
LogMessage -Message "Credential Providers exported to:"
LogMessage -Message $newlogfolder\credprov.txt
LogMessage -Message ==============================================================================
LogMessage -Message "Duo.log exported to:"
LogMessage -Message $newlogfolder\Duo.Log 
LogMessage -Message ==============================================================================
LogMessage -Message "Network settings exported to:"
LogMessage -Message $newlogfolder\NetworkSettings.txt
LogMessage -Message ==============================================================================
LogMessage -Message "Duo Registry Keys:" 
If (Test-Path -Path $localreg) {
(Get-ItemProperty $localreg | Select-Object * -ExcludeProperty SKey,PS* | fl | Out-File $LogFile -force -Append)
} else {LogMessage -Message "Duo Registry Keys Not Present"}
LogMessage -Message ==============================================================================
LogMessage -Message "Offline Registry Keys:" 
If (Test-path -Path "$localreg\offline"){
(Get-ItemProperty "$localreg\offline" | Select-Object * -ExcludeProperty PS* | fl | Out-File $LogFile -force -Append)
}
else {LogMessage -Message "Duo Offline Not Present"  }
LogMessage -Message ============================================================================== 
$duoTime = Invoke-RestMethod -Uri "https://api.duosecurity.com/auth/v2/ping"
$duounixtimestamp = $duoTime.response.time
$MaxDateTime = (Get-Date).ToUniversalTime().AddMinutes(2)
$MaxPCTime = [System.Math]::Truncate((Get-Date -Date $MaxDateTime -UFormat %s))
$MinDateTime = (Get-Date).ToUniversalTime().AddMinutes(-2)
$MinPCTime = [System.Math]::Truncate((Get-Date -Date $MinDateTime -UFormat %s))
$timesource = w32tm /query /source
LogMessage -Message "NTP Settings:"
LogMessage -Message "Time Source: $($timesource) "
if ($MinPCTime -ge $duounixtimestamp -and $MaxPCTime -le $duounixtimestamp) {
  LogMessage -Message:"Time is currently out of Sync with Duo Service"
 }
 else {
  LogMessage -Message:"Time is within valid range of Duo Service"
 }
LogMessage -Message ============================================================================== 
$UserHT = @{0 = "Automatically deny elevation requests"; 1 = "Prompt for credentials on the secure desktop"; 3 = "(Default) Prompt for credentials"}
$AdminHT = @{0 = "Elevate without prompting"; 1 = "Prompt for credentials on the secure desktop"; 2 = "Prompt for consent on the secure desktop"; 3 = "Prompt for credentials"; 4 = "Prompt for consent"; 5 = "(Default) Prompt for consent for non-Windows binaries"}
$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
$ConsentPromptBehaviorUser_Name = "ConsentPromptBehaviorUser" 

$ConsentPromptBehaviorAdmin_Value = Get-ItemPropertyValue $Key $ConsentPromptBehaviorAdmin_Name 
$ConsentPromptBehaviorUser_Value = Get-ItemPropertyValue $Key $ConsentPromptBehaviorUser_Name 
LogMessage -Message "UAC Settings:"
LogMessage -Message  "User UAC Settings: $($UserHT.$ConsentPromptBehaviorUser_Value) "
LogMessage -Message  "Administrator UAC Settings: $($AdminHT.$ConsentPromptBehaviorAdmin_Value) "

#Conditonal log for app/sec logs
If ($eventlogs -eq "application" -or $eventlogs -eq "all"){
LogMessage -Message "Application Event Log exported to:"
LogMessage -Message "$newlogfolder\security.evtx"
LogMessage -Message ==============================================================================
}
If ($eventlogs -eq "security" -or $eventlogs -eq "all"){
LogMessage -Message "Security Event Log exported to:"
LogMessage -Message "$newlogfolder\security.evtx"
LogMessage -Message ==============================================================================
}
If ($tls){
	if (Test-path -path Registry::"HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client")
		{$SSL2ClientReg = Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client"}
	if (Test-path -path Registry::"HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client")
		{$SSL3ClientReg = Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client"}
	if (Test-path -path Registry::"HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client")
		{$TLS1ClientReg = Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"}
	if (Test-path -path Registry::"HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client")
		{$TLS11ClientReg = Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client"}
	if (Test-path -path Registry::"HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client")
		{$TLS12ClientReg = Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"}
	
    if ($SSL3ClientReg.Enabled -ne 0)
		 {LogMessage -Message "SSL3 is Enabled (NOT default)"}
		else
			 {LogMessage -Message "SSL3 is Disabled (default)"}
	
    if ($TLS1ClientReg.Enabled -ne 0) 
		 {LogMessage -Message "TLS 1.0 is Enabled (default)"}
		else
			 {LogMessage -Messaget "TLS 1.0 is Disabled (NOT default)"}
	 
    if ($TLS11ClientReg.Enabled -ne 0)
		 {LogMessage -Message "TLS 1.1 s Enabled (default)"}
		else
			 {LogMessage -Message "TLS 1.1 is Disabled (NOT default)"}
	 
    if ($TLS12ClientReg.Enabled -ne 0)
		 {LogMessage -Message "TLS 1.2 is Enabled (default)"}
		else
			 {LogMessage -Message "TLS 1.2 is Disabled (NOT default)"}
LogMessage -Message ==============================================================================
}

#print messages
cat $LogFile

#export to zip
$srcdir = "$newlogfolder"
$zipFilename = "DuoSupport$(get-date -f yyyy-MM-dd-hh-mm-ss).zip"
$zipFilepath = "$out"
$zipFile = "$zipFilepath$zipFilename"

#Prepare zip file
if(-not (test-path($zipFile))) {
    set-content $zipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
    (dir $zipFile).IsReadOnly = $false  
}

$shellApplication = new-object -com shell.application
$zipPackage = $shellApplication.NameSpace($zipFile)
$files = Get-ChildItem -Path $srcdir | where{! $_.PSIsContainer}

foreach($file in $files) { 
    $zipPackage.CopyHere($file.FullName)
#using this method, sometimes files can be 'skipped'
#this 'while' loop checks each file is added before moving to the next
    while($zipPackage.Items().Item($file.name) -eq $null){
        Start-sleep -seconds 1
    }
}
#remove temp folder
Remove-Item $newlogfolder -recurse -force

#support file path
$t = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "DarkGreen"
Write-Output "Please send $zipfile to Duo Support"
$host.ui.RawUI.ForegroundColor = $t
}
