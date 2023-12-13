$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
Connect-MSOLService -Credential $adminCredential

$AccountSkuId = "livetcicollege:STANDARDWOFFPACK_STUDEN"

$UsageLocation = "US"
 
 Set-MsolUserLicense -UserPrincipalName jorti166002@live.tcicollege.edu -RemoveLicense $AccountSkuId

$Users = Import-Csv c:\office365\export.csv

$Users | ForEach-Object {



Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -RemoveLicense $AccountSkuId 

}

Get-MsolAccountSku




Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq 'EXCHANGESTANDARD_STUDENT'} |
   ForEach-Object {$_.ServiceStatus}

   Set-MsolUserLicense -AddLicenses "livetcicollege:STANDARDWOFFPACK_STUDENT"



$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
Connect-MSOLService -Credential $adminCredential
Connect-MSOLService -Credential $adminCredential
Get-MsolUser -all | Where {$_.Licenses.AccountSkuId -contains "livetcicollege:EXCHANGESTANDARD_STUDENT"} | 
-RemoveLicenses "livetcicollege:EXCHANGESTANDARD_STUDENT"

$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
Connect-MSOLService -Credential $adminCredential
Get-Mailbox cbrya579882@live.tcicollege.edu |fl

$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Import-module Msonline
Connect-MsolService -Credential $Livecred


get-user cbrya579881@livetcicollege.onmicrosoft.com | fl

 $search="Bryant, Christia K" 
get-mailbox -ResultSize Unlimited| Where-Object { $_.EmailAddresses -like "*" + $search + "*"} |fl EmailAddresses 

Get-MsolAccountSku | Select AccountSkuId


$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
Connect-MSOLService -Credential $adminCredential
try {
    $Users = Get-MsolUser -All | Where-Object { $_.Licenses.AccountSkuId -eq "livetcicollege:EXCHANGESTANDARD_STUDENT" }
} catch {
    write-host ("Caught error: " + $_.Exception) -ForeGroundColor Red;
    exit
}
if ($Users -ne $null) {
    foreach ($user in $Users) {
        $process_date = Get-Date -format "MM/dd/yyyy HH:mm:ss"
        $UPN = $user.UserPrincipalName
        if ($UPN -eq "jmortiz@live.tcicollege.edu") {
            write-host "[INFO] Skipping admin account"
        } else {  
            try {
                write-host "[INFO] Processing $UPN" -ForegroundColor Yellow
                $options = New-MsolLicenseOptions -AccountSkuId "livetcicollege:STANDARDWOFFPACK_STUDENT"  -ErrorAction Stop
                Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicense "livetcicollege:EXCHANGESTANDARD_STUDENT"
                Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "livetcicollege:STANDARDWOFFPACK_STUDENT" -LicenseOptions $options -ErrorAction "Stop"
                write-host "[INFO] Updated $UPN license" -ForegroundColor Green
            } catch {
                write-host "[CRITICAL] Unable to update $UPN license. See exception : $($_.Exception)" -ForegroundColor Red
            }
        }
 
    }
}

$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
Connect-MSOLService -Credential $adminCredential
try {
    $Users = Get-MsolUser -All | Where-Object { $_.isLicensed -eq "FALSE" } 
} catch {
    write-host ("Caught error: " + $_.Exception) -ForeGroundColor Red;
    exit
}
if ($Users -ne $null) {
    foreach ($user in $Users) {
        $process_date = Get-Date -format "MM/dd/yyyy HH:mm:ss"
        $UPN = $user.UserPrincipalName
        if ($UPN -eq "jmortiz@live.tcicollege.edu") {
            write-host "[INFO] Skipping admin account"
        } else {
            try {
                write-host "[INFO] Processing $UPN" -ForegroundColor Yellow
                $options = New-MsolLicenseOptions -AccountSkuId "livetcicollege:STANDARDWOFFPACK_STUDENT" -DisabledPlans SHAREPOINTWAC_EDU,SHAREPOINTSTANDARD_EDU -ErrorAction Stop
                Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "livetcicollege:STANDARDWOFFPACK_STUDENT" -LicenseOptions $options -ErrorAction "Stop"
                write-host "[INFO] Updated $UPN license" -ForegroundColor Green
            } catch {
                write-host "[CRITICAL] Unable to update $UPN license. See exception : $($_.Exception)" -ForegroundColor Red
            }
        }
 
    }
}

Get-Mailbox cbrya579881@livetcicollege.onmicrosoft.com | fl
Get-Mailbox cbrya579881@live.tcicollege.edu | fl
Get-User 	cbrya579881@livetcicollege.onmicrosoft.com | fl
Get-User    cbrya579881@live.tcicollege.edu | fl
Get-MsolUser cbrya579881@livetcicollege.onmicrosoft.com | fl
Get-MsolUser cbrya579881@live.tcicollege.edu | fl