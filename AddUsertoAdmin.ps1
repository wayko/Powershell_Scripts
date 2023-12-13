$Password = ConvertTo-SecureString "password" -AsPlainText -Force
New-LocalUser -Name "username" -Password $Password -FullName "username"
Add-LocalGroupMember -Group Administrators  -Member JSHloadme -Verbose