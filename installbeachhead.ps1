$installerPath = "\\001100ATLMAN01\Beachhead MSI\Beachhead_Agent_v6.8.1_Bronx_Installer_Best Choice HHC - Bronx.msi"

try
{
 msiexec.exe  /i $installerPath /norestart /quiet
}
catch
{
    write-host $_
}

