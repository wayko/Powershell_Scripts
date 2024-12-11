$source = "https://prod.setup.itsupport247.net/windows/BareboneAgent/32/Bloomfield-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513/MSI/setup"
$destination = "c:\users\public\downloads\agent.msi"
Invoke-WebRequest -Uri $source -OutFile $destination 
Start-Process "C:\Windows\System32\msiexec.exe"  -ArgumentList "/i $destination /norestart /quiet"  -Wait 