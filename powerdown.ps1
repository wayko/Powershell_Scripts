$currentTime = get-date -uformat "%r"
$targetTime = [DateTime]::ParseExact('12:00:00 AM', "hh:mm:ss tt", $null)
$turnOff = $targetTime.ToLongTimeString()
$timeDiff = NEW-TIMESPAN -start $turnOff -End  $currentTime
$timeDiff
if($timeDiff.Hours -ge $currentTime)
{
   stop-computer -WhatIf
}
else
{
    "It's less than an hour"
}