$appdatafolder  = "$user\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"
        Remove-Item -Path $appdatafolder\*.* -Force -ErrorAction SilentlyContinue
        Get-PnPFile -Url $FileRelativeURL  -Path $appdatafolder -Filename $guidfileName -asFile -ErrorAction SilentlyContinue
        Get-PnPFile -Url $FileRelativeURL  -Path $appdatafolder -Filename $guidthumb -asFile -ErrorAction SilentlyContinue
        Get-PnPFile -Url $FileRelativeURL2  -Path $appdatafolder -Filename $guidfileName2 -asFile -ErrorAction SilentlyContinue
        Get-PnPFile -Url $FileRelativeURL2  -Path $appdatafolder -Filename $guidthumb2 -asFile -ErrorAction SilentlyContinue
    }
    else
    {
       $appdatafolder = "$user\appdata\roaming\Microsoft\Teams\Backgrounds\Uploads"
       Get-PnPFile -Url $FileRelativeURL  -Path $appdatafolder -Filename "Woodmont-TeamsBackground-202310.jpg" -asFile -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
       Get-PnPFile -Url $FileRelativeURL2  -Path $appdatafolder -Filename "Woodmont-TeamsBackground-2024.jpg" -asFile -ErrorAction SilentlyContinue -WarningAction SilentlyContinue