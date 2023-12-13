Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} 


Get-AppxPackage -alluser Microsoft.WindowsStore| Remove-Appxpackage