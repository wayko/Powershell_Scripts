$originalPath =  'F:\Y drive\'
$newPath = "d:\Y drive\"

Copy-Item -path $originalPath -Destination $newPath -Recurse

$Folders = Get-ChildItem -Path $originalPath -Recurse -Directory
foreach($folder in $Folders)
{
  if((Get-Item $folder.FullName | get-acl).Access | where {$_.IsInherited -eq $false})
  {
    $substring = $folder.FullName.Substring(("f:\Y drive").Length+1)
    $DPath = $originalPath
    $ZPath = $newPath
    $fullDString = $DPath + $substring
    $fullZString = $ZPath + $substring
   
    Get-ACL $fullDString | Set-ACL $fullZString

    $folder.FullName
    Get-Acl $folder.FullName| Select -ExpandProperty Access | ft IdentityReference, Filesystemrights, IsInherited, InheritanceFlags
  }
  else
  {
    $substring = $folder.FullName.Substring(("f:\Y drive").Length+1)
    $DPath = $originalPath
    $ZPath = $newPath
    $fullDString = $DPath + $substring
    $fullZString = $ZPath + $substring

    Get-ACL $fullDString | Set-ACL $fullZString

    $folder.FullName
    Get-Acl $folder.FullName| Select -ExpandProperty Access | ft IdentityReference, Filesystemrights, IsInherited, InheritanceFlags
  }
  
}
