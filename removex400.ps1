$Users = Get-ADUser -Filter * -pr proxyaddresses
foreach ($user in $Users) {
    $User.proxyaddresses | Where-Object {($_ -like "*x400*") } |
    ForEach-Object {
        Get-ADuser $user.DistinguishedName | Set-ADuser -remove @{proxyaddresses = $_ } -whatif
        Write-Host "Removing "$_" from " $User.name "'s Proxy address" -ForegroundColor Red
       }
}