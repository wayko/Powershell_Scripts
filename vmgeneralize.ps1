#Exchange 2k13 SP1

param(
[int] $len = 12,
[string] $chars = "0123456789abcdef"
)


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
$exmacaddress = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]

Get-VM -Name "Exchange 2k13 SP1"|Set-VMNetworkAdapter -StaticMacAddress $exmacaddress
$exmacaddress

#Fedora 19

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
$fedmacaddress = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]

Get-VM -Name "Fedora 19"|Set-VMNetworkAdapter -StaticMacAddress $fedmacaddress
$fedmacaddress

#Windows 2k12 R2

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
$2k12macaddress = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]

Get-VM -Name "Windows 2k12 R2"|Set-VMNetworkAdapter -StaticMacAddress $2k12macaddress
$2k12macaddress

#Windows 2k8 R2

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
$2k8macaddress = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]

Get-VM -Name "Windows 2k8 R2"|Set-VMNetworkAdapter -StaticMacAddress $2k8macaddress
$2k8macaddress

#Windows 8.1 Network

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
$win81macaddress = $macraw[0]+$macraw[1]+":"+$macraw[2]+$macraw[3]+":"+$macraw[4]+$macraw[5]+":"+$macraw[6]+$macraw[7]+":"+$macraw[8]+$macraw[9]+":"+$macraw[10]+$macraw[11]

Get-VM -Name "Windows 8.1 Network"|Set-VMNetworkAdapter -StaticMacAddress $win81macaddress
$win81macaddress