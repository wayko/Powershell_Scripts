$fileA = "F:\Text Files\55Printer.txt"
$fileB = "F:\Text Files\150Printer.txt"

$first = Get-Content $fileA
$second = Get-Content $fileB

Compare-Object $first $second |  where { $_.SideIndicator -eq '=>'}