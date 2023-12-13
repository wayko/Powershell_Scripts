$KworkingFolder = (Get-Item -Path env:KWORKDIR).value

$csvfiles = Get-ChildItem "$KworkingFolder\Klogs" | Select-Object -ExpandProperty Name | ForEach-Object {$_.replace('.csv','')}
$counters = Foreach ($a in $csvfiles) {$a.replace('KLOG','KCTR')}

ForEach ($i in $counters) {
&logman.exe stop $i
&logman.exe delete $i
}

$kdir = Get-Childitem 'C:\Program Files (x86)\Kaseya' | Select-Object -ExpandProperty Name

foreach($dir in $kdir){

Start-Process -FilePath "C:\Program Files (x86)\Kaseya\$dir\KASetup.exe" -ArgumentList "/s","/r","/g $kdir","/l %temp%\kasetup.log"
}



