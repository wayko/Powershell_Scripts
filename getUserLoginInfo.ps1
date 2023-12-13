$logs = Get-WinEvent "Microsoft-WIndows-User Profile Service/Operational" 

ForEach ($log in $logs) 
{
    if($log.id -eq 2) 
    {
        $type = "Logon"
    } 
    Elseif($log.id -eq 4)
    {
    $type="Logoff"
    }
    $log.TimeCreated
    $type
    write-host("-------------------------")   
}