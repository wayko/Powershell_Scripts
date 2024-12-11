$users = Import-Csv C:\championpw.csv

foreach($user in $users){

   Set-ADUser -identity $user -ChangePasswordAtLogon $true
}