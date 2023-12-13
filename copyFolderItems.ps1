$orig = "J:\"
$new = "k:\"


$what = @("/COPY:DATSO")
$options = @("/R:0","/W:0","/NFL","/NDL")

$cmdArgs = @("$orig","$new",$what,$options)
robocopy @cmdArgs
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -Type DWord -Value 1