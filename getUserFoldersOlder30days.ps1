$omit = ".NET v2.0"
$omit2 = ".NET v2.0 Classic"
$omit3 = ".NET v4.5"
$omit4 = ".NET v4.5 Classic"
$omit5 = "Classic .NET AppPool"
$omit6 = "DefaultAppPool"
$omit7 = "Public"
$omit8 = "TEMP"
$omit9 = "Default"
$folders = Get-ChildItem C:\Users -Directory | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit5 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit6 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit7 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit8 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit9 -and $_.PsIsContainer)}

foreach($folder in $folders)
{

    if($folder.LastWriteTime -le (get-date).AddDays(-30))
    {
    
    $folder | Select-Object name, creationtime
    #$folder | remove-item 
    
    }
}

(Get-Item "C:\Users\Test").LastAccessTime = '01/11/2002 06:00:36'

foreach($folder in $folder2)
{
    $folder | % {$_.LastWriteTime = '01/11/2005 06:01:36'}

    $folder.LastWriteTime
}
