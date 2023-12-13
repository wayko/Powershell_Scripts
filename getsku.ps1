
$managerun = 'jmortiz@live.tcicollege.edu'
$managerpw = ConvertTo-SecureString 'Wayko621' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

connect-msolservice -credential $LiveCred
Get-MsolAccountSku