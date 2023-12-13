$Folders = Get-ChildItem -Path f:\Test -Recurse -Directory

foreach($folder in $Folders)
{
 $folderPerm = "DBCLOUD\$folder"
 $folderperm
 $acl = get-acl $folder.FullName
 $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($folderPerm,"FullControl","Allow")
$acl.SetAccessRule($AccessRule)

}