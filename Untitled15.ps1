$folders = get-childitem f:\test -Directory -Recurse

foreach($folder in $folders)
{
  
     $folderDepth = 1
  $folderIndex = $folder.FullName.ToString().split('\\').Count
  #get-acl Get-childitem ((((Get-childitem $folder.FolderLocation -Depth 0 -Directory).Parent).Parent).Parent).FullName -directory  | Select -ExpandProperty Access | ft IdentityReference, Filesystemrights, IsInherited, InheritanceFlags 
       
        if($folder.Name -eq "Admin")
        {
             write-host "Folder found at depth $folderIndex" 
             $adminIndex = $folderIndex
        }  
        
        while($folderDepth -le $adminIndex)
        {
          $folderDepth = ($folderDepth + 1)
          $folderDepth
        }
}