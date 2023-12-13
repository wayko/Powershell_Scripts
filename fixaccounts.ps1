$cred = get-credential
Connect-MSOLService –credential $cred
$userUPN = "aalsa675018@live.tcicollege.edu"
get-MSOLUser –UserPrincipalName $userUPN | where {$_.LastDirSyncTime -eq $null}
$SessionExO = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $sessionExO -prefix:Cloud
$proxyAddress = "aalsa675018@live.tcicollege.edu"

get-mailbox | where {[string] $str = ($_.EmailAddresses); $str.tolower().Contains($proxyAddress.tolower()) 
-eq $true} | foreach {get-MSOLUser -UserPrincipalName $_.MicrosoftOnlineServicesID | 
where {($_.LastDirSyncTime -eq $null)}}