Invoke-WebRequest -Uri "https://work-desktop-assets.8x8.com/prod-publish/ga/work-64-msi-v8.15.2-7.msi" -Outfile c:\temp\work-64-msi-v8.15.2-7.msi

Start-Process C:\windows\system32\msiexec.exe -ArgumentList "/i  c:\temp\work-64-msi-v8.15.2-7.msi /qn /norestart" -wait