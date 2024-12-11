$source = "https://prod.setup.itsupport247.net/windows/BareboneAgent/32/Bloomfield-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513/MSI/setup"

$destination = "c:\users\public\downloads\Bloomfield-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513.msi"

Invoke-WebRequest -Uri $source -OutFile $destination 
Start-Process "C:\Windows\System32\msiexec.exe"  -ArgumentList "/i $destination /norestart /qn /L*v c:\result.log"

$moorseSource = "https://prod.setup.itsupport247.net/windows/BareboneAgent/32/Moorestown-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKNef189676-98d9-4542-a534-0ed6d87f8e1b/MSI/setup"
$destinationMoorse = "c:\users\public\downloads\Moorestown-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKNef189676-98d9-4542-a534-0ed6d87f8e1b.msi"
Invoke-WebRequest -Uri $moorseSource -OutFile $destinationMoorse 
Start-Process "C:\Windows\System32\msiexec.exe"  -ArgumentList "/i $destinationMoorse /norestart /qn /L*v c:\result.log"



curl -L -o  "c:\users\public\downloads\Bloomfield-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513.msi" "https://prod.setup.itsupport247.net/windows/BareboneAgent/32/Bloomfield-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513/MSI/setup"
msiexec /i "c:\users\public\downloads\Bloomfield-Atlantic_Tomorrow's_Office_Windows_OS_ITSPlatform_TKN7bf933ee-0f40-4980-81ee-4c4612924513.msi" /qn /norestart