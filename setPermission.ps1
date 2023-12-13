$NewAcl = Get-Acl "E:\Shared\1Municipal-College Clients\TEST-1\Policies"

$Folders = Get-ChildItem -Path "E:\Shared\1Municipal-College Clients\TEST-1\" -Recurse -Force 




foreach($folder in $Folders)
{
   Set-Acl -Path $folder.FullName -aclobject $NewAcl
}