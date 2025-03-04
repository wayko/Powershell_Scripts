$Usersfolders = Get-ChildItem -Path E:\ -Recurse -Directory -Depth 2
$papercut = "CENTERLIGHT\zpapercut"
$fileSystemRights = "FullControl"
$type = "Allow"
 
$fileSystemAccessRuleArgumentList = $papercut, $fileSystemRights, $type
 
$fileSystemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($fileSystemAccessRuleArgumentList)
 
 
foreach($folder in $Usersfolders)
{
    if($folder.FullName -eq "E:\LaptopResources" -or $folder.FullName -eq "E:\Category" -or $folder.FullName -eq "E:\!ATOTest")
    {
        write-host "Skipping Folder"
    }
    else
    {
        $NewAcl = Get-ACL -path $folder.FullName
        $NewAcl.SetAccessRule($fileSystemAccessRule)
        $newACL | Set-Acl $folder.FullName
        write-host "zpapercut has been given full access to " + $folder.FullName 
    }
    
}