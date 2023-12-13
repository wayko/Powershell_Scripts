$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
connect-msolservice -credential $adminCredential
try {
    $Users = Get-MsolUser -All | Where-Object { $_.Licenses.AccountSkuId -eq "" }
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
                Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicense "livetcicollege:EXCHANGESTANDARD_STUDENT"
                Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "livetcicollege:STANDARDWOFFPACK_STUDENT" -LicenseOptions $options -ErrorAction "Stop"
                Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "livetcicollege:OFFICESUBSCRIPTION_STUDENT" -LicenseOptions $options -ErrorAction "Stop"
                write-host "[INFO] Updated $UPN license" -ForegroundColor Green
            } catch {
                write-host "[CRITICAL] Unable to update $UPN license. See exception : $($_.Exception)" -ForegroundColor Red
            }
        }
 
    }
}

Get-MsolAccountSku