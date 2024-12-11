$Thumbprint = "7f 0f dc b9 50 ca 47 af ce e7 ba 72 e0 c7 24 da c4 10 ac f8"
$Thumbprint = $Thumbprint.Replace(' ','')
Get-ChildItem -Path Cert:\LocalMachine\ -Recurse | ? {$_.Thumbprint -like $Thumbprint } | Remove-Item