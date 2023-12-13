try{
get-childitem -path HKLM:\SOFTWARE -Recurse | Where-Object {$_.Name -ne "*Fortikey*"}
write-host "Key Found"
}
catch
{
}