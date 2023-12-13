Import-Module ActiveDirectory 
$users = get-aduser -filter * -properties * | Select-Object SamAccountName, accountexpires, accountlockouttime, badlogoncount, padpwdcount, lastbadpasswordattempt, lastlogondate, lockedout, passwordexpired, passwordlastset, pwdlastset 

foreach ($user in $users)
{
    $user
}


Get-ADOrganizationalUnit -filter * | Select-Object DistinguishedName |Sort-Object DistinguishedName


Search-ADAccount –LockedOut -SearchBase "OU=User Admin,OU=Admin Accounts,DC=edisonschools,DC=net"  | Unlock-ADAccount
