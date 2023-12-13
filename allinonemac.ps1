
param(
[int] $len = 12,
[string] $chars = "0123456789abcdef"
)
$macarray = New-Object System.Collections.ArrayList
for ($j= 0; $j -lt 5; $j++)
{
$macadd = "macadd"
$macaddress = $macadd+$j
$bytes = new-object "System.Byte[]" $len

$rnd = new-object System.Security.Cryptography.RNGCryptoServiceProvider
$rnd.GetBytes($bytes)

#define the fields
$macraw = ""

for( $i=0; $i -lt $len; $i++ )
{
$macraw += $chars[ $bytes[$i] % $chars.Length ]
}

#add collons to the random macraw so that it is properly formatted
$macaddress  = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]
$macarray.add($macaddress.ToString())
}

$Stoploop = $false
[int]$Retrycount = "0"
 
do {
	try {
		Get-VM -Name "Exchange 2k13 SP1"|Set-VMNetworkAdapter -StaticMacAddress $macarray[0]
        Get-VM -Name "Fedora 19"|Set-VMNetworkAdapter -StaticMacAddress $macarray[1]
        Get-VM -Name "Windows 2k12 R2"|Set-VMNetworkAdapter -StaticMacAddress $macarray[2]
        Get-VM -Name "Windows 2k8 R2"|Set-VMNetworkAdapter -StaticMacAddress $macarray[3]
        Get-VM -Name "Windows 8.1 Network"|Set-VMNetworkAdapter -StaticMacAddress $macarray[4]
		Write-Host "Job completed"
		$Stoploop = $true
		}
	catch {
		if ($Retrycount -eq 5){
			Write-Host "Could not send Information after 5 retrys."
			$Stoploop = $true
		}
		else {
			Write-Host "Could not send Information retrying in 3 seconds..."
			Start-Sleep -Seconds 3
			$Retrycount = $Retrycount + 1
		}
	}
}
While ($Stoploop -eq $false)
