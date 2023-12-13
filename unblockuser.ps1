$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw
connect-msolservice -credential $LiveCred
get-msoluser -All | where {$_.blockcredential –eq “true”} | export-csv g:\userswhoareblocked.csv
Set-MsolUser -UserPrincipalName dmash716108@live.tcicollege.edu –blockcredential $false