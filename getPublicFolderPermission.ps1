$users = Get-mailbox

foreach($user in $users){
    add-publicfolderclientpermission -identity "\Public Folder\Events" -user $user.alias -accessrights "PublishingEditors"
}