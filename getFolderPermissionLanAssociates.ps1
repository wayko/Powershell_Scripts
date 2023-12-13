$Folders = Get-ChildItem -Path E:\Project_Sources -Recurse -Directory  
$containsFolder = @()
foreach ($folder in $Folders)
{
    #Get Admin folder location
    if($folder.name -eq "Admin")
    {
        $folderIndex = $folder.FullName.ToString().Split('\\').Count
        $containsFolder += $folder.FullName 
    }
    
    #Get Cad folder location
    if($folder.name -eq "Cad")
    {
        $folderIndex2 = $folder.FullName.ToString().Split('\\').Count
        $containsFolder += $folder.FullName
    }

    

    
}
foreach($foundFolder in $containsFolder)
{
   $folderIndex4 = $foundFolder.ToString().Split('\\').Count
   $foundFolder.ToString() + ' Index:' + $folderIndex4


}
if($folder.FullName.ToString().Split('\\').Count -ge 3 -and  $folder.FullName.ToString().Split('\\').Count -lt $folderIndex)
    {
        $folderIndex3 = $folder.FullName.ToString().Split('\\').Count
        $folder.FullName + ' Index ID:' + $folderIndex3
        Get-Acl $folder.FullName| Select -ExpandProperty Access | ft IdentityReference, Filesystemrights, IsInherited, InheritanceFlags
    }

#| Select-Object @{N="Path Length";E={$_.FullName.Length}}, FullName | Format-Table -AutoSize |Tee-Object C:\users\administrator.LANNJ\Desktop\filepath.csv -Append
