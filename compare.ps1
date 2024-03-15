$fileA = "F:\Text Files\sonicwallconfig1.txt"
$fileB = "F:\Text Files\sonicwallconfig2.txt"

$first = Get-Content $fileA
$second = Get-Content $fileB

Compare-Object  $second $first|  where { $_.SideIndicator -eq '=>'}