$username = "username"
$password = "password"
$secPw = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object PSCredential -ArgumentList $username,$secPw
Invoke-WebRequest http://172.22.1.189/webapps/bb-data-integration-flatfile-BBLEARN/endpoint/person/store -Credential $cred -ContentType:text/plain -Method Post -InFile '\\10.15.10.96\Blackboard\Bb Push\CVUE_OUTBOUND\Users.txt'