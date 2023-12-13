$managerun = 'email'
$managerpw = ConvertTo-SecureString 'password' -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $managerun,$managerpw

connect-msolservice -credential $LiveCred
$username = Read-Host "Enter username"
$password = Read-Host "Enter password"
Set-MsolUserPassword -UserPrincipalName $username -NewPassword (ConvertTo-SecureString -String $password -AsPlainText -Force) -ForceChangePassword $false

"Your Username is $username and your password is $password" | Out-File C:\powershell\PasswordOutput.txt -width 50
$WordObj=New-Object -ComObject Word.Application
$WordObj.Documents.Add('C:\powershell\PasswordOutput.docx') > $null
$WordObj.ActiveDocument.Content.Font.Size = 12
$WordObj.ActiveDocument.Content.Font.Name = "Verdana"
$WordObj.ActiveDocument.Content
#Send To Default Printer
$WordObj.PrintOut()

#Close File without saving
$WordObj.ActiveDocument.Close(0)
$WordObj.quit() 
if(Select-String C:\powershell\mailandportal.txt -pattern "username:")
{ 
add-content C:\powershell\mailandportal.txt "$username"
} 
Get-MsolAccountSku