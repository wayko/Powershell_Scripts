$Folders = Get-ChildItem -Path f:\Test -Recurse -Directory
$secondFolder = Get-ChildItem -Path g:\test -Recurse
foreach($folder in $Folders)
{
    
    

  if((Get-Item $folder.FullName | get-acl).Access | where {$_.IsInherited -eq $false})
  {
   $folder.FullName

  }
}

get-acl -path f:\test | set-acl -path g:\test


Get-Acl $folder.FullName| Select -ExpandProperty Access | ft name,IdentityReference, Filesystemrights, IsInherited, InheritanceFlags | ? inheritanceflags -eq ‘None’