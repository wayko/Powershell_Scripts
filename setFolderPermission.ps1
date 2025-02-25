$Usersfolders = Get-ChildItem -Path D:\Test -Recurse -Directory  
$papercut = "DEVDOGZ-PC\papercut"
$fileSystemRights = "FullControl"
$type = "Allow"

$fileSystemAccessRuleArgumentList = $papercut, $fileSystemRights, $type

$fileSystemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($fileSystemAccessRuleArgumentList)



foreach($folder in $Usersfolders)
{
    $NewAcl = Get-ACL -path $folder.FullName
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    $newACL | Set-Acl $folder.FullName
}