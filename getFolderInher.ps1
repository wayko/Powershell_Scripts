$Folders = Get-ChildItem -Path f:\ -Recurse
foreach($folder in $Folders)
{

 Get-Acl $folder.FullName | 
            select -ExpandProperty Access | 
            where { $_.IsInherited -eq $false }
}