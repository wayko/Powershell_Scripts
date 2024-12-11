$omit = "Admin"
$omit2 = "Cad"
$omit3 = "20000-AE"
$omit4 = "Proposal"

$Folders = Get-ChildItem -Path "P:\100-LAN LLP" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders2 = Get-ChildItem -Path "P:\300-EE" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders3 = Get-ChildItem -Path "P:\400-House_Insp" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders4 = Get-ChildItem -Path "P:\500-AR" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders5 = Get-ChildItem -Path "P:\600-SP" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders6 = Get-ChildItem -Path "P:\800-Survey" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders7 = Get-ChildItem -Path "P:\900-VR" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 
$Folders8 = Get-ChildItem -Path "P:\200-AE" -Recurse -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("LANNJ\Domain Users","write","deny")
#$AccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("LANNJ\Domain Users","Read","Allow")
$AccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("LANNJ\P Drive - DenyWrite","write","deny")

 foreach($folder8 in $Folders8)
{
    $folder8.FullName
    $acl = get-acl $folder.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder8.FullName
    get-acl $folder8.FullName | fl
}

foreach($folder in $Folders)
{
    $acl = get-acl $folder.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder.FullName 
    get-acl $folder.FullName | fl
}

foreach($folder2 in $Folders2)
{
    $acl = get-acl $folder2.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder2.FullName
    get-acl $folder2.FullName | fl
}

foreach($folder3 in $Folders3)
{
    $acl = get-acl $folder3.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder3.FullName  
    get-acl $folder.FullName | fl
}

foreach($folder4 in $Folders4)
{
    $acl = get-acl $folder4.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder4.FullName  
    get-acl $folder.FullName | fl
}

foreach($folder5 in $Folders5)
{
    $acl = get-acl $folder5.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder5.FullName 
    get-acl $folder5.FullName | fl
}

foreach($folder6 in $Folders6)
{
    $acl = get-acl $folder6.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder6.FullName    
    get-acl $folder6.FullName | fl
}

foreach($folder7 in $Folders7)
{
    $acl = get-acl $folder7.FullName 
    $acl.RemoveAccessRule($AccessRule)
    #$acl.SetAccessRule($AccessRule2)
    $acl.SetAccessRule($AccessRule3)
    $acl | Set-Acl $folder7.FullName  
    get-acl $folder7.FullName | fl
}
