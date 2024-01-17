$ddrive = Get-ChildItem d:\ -Recurse 

get-acl D:\data\Bookeepers | set-acl E:\data\Bookeepers 
get-acl D:\data\Results | set-acl E:\data\Results

get-acl D:\data\scans | set-acl E:\data\scans
get-acl 'D:\data\User Backups' | set-acl 'E:\data\User Backups'
get-acl D:\data\userpsts | set-acl E:\data\userpsts
get-acl D:\data\users | set-acl E:\data\users


$folder = get-childitem D:\data\users -Recurse -Directory

foreach($folders in $folder)
{
    $foldername = $folders.fullname.Substring(3)
    $ddrive = "D:\$foldername"
    $edrive = "E:\$foldername"
    get-acl $ddrive | set-acl $edrive
}