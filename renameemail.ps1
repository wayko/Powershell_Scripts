$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

connect-msolservice -credential $LiveCred

$oldemail = Read-Host "Enter Old Email"
$newemail = Read-Host "Enter New Email"

Set-MsolUserPrincipalName -UserPrincipalName $oldemail -NewUserPrincipalName $newemail