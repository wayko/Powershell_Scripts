$users = get-aduser -Filter *

foreach($user in $users)
{
 $firstName = $user.GivenName
 $lastName = $user.Surname
 $newDisplayName = $firstName + ' ' + $lastName
 $newDisplayName
 set-aduser $user.SamAccountName -Replace @{displayName=$newDisplayName} 

 }