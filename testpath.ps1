if ((Test-Path -Path "C:\Windows\winip.bin") -or (Test-Path -Path "C:\Windows\winip.bak") -or (Test-Path -Path "C:\Windows\syswow64\winip.dat") -or (Test-Path -Path "C:\Windows\syswow64\winip.bak"))
{
  write-host "File Exist"
}
else
{
  write-host "File does not exist"

}