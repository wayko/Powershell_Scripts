Install-Module -Name NTFSSecurity
$Usersfolders = Get-ChildItem -Path E:\ -Recurse -Directory -Depth 3
$papercut = "CENTERLIGHT\zpapercut"
$fileSystemRights = "FullControl"
$type = "Allow"
 
$fileSystemAccessRuleArgumentList = $papercut, $fileSystemRights, $type
 
$fileSystemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($fileSystemAccessRuleArgumentList)
 
 
foreach($folder in $Usersfolders)
{
    if($folder.FullName -eq "E:\ThisIsTest" -or $folder.FullName -eq "E:\Category")
    {
        write-host "Skipping Folder"
    }
    else
    {
        #$NewAcl = Get-ACL -path $folder.FullName
        #$NewAcl.SetAccessRule($fileSystemAccessRule)
        #$newACL | Set-Acl $folder.FullName
        Add-NTFSAccess -Path $folder.FullName -Account $papercut -AccessRights FullControl
        write-host "zpapercut has been given full access to " + $folder.FullName
        
    }
    
}





