 #variables .Change as per your needs
 $username = "administrator"; 
$computer="10.128.100.141"    #Change this
$password ="Welcome12345!"    #Change this
 #No need to Change the below lines
$EnableUser = 512
try {
$user = [ADSI]"WinNT://$computer/$username";
$user.SetPassword($password);
$user.UserFlags =$EnableUser     
 $user.setinfo()
Write-Host "Success" -ForegroundColor green
 }
 catch
 {
 write-host "an error occured $_" -ForegroundColor Red
 }