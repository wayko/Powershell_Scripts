$bomgar = "\\001100atlman02\New_Bomgar\New Bomgar\bomgar-scc-w0fdc30f77yzd6hw7yd1iyi6x877d65hg77yi6ic408c90.exe"

Start-Process $bomgar

Start-Sleep -seconds 40
$iconfile = Get-ChildItem "C:\ProgramData\bomgar-scc-cb\support.centerlight.org"
foreach($icon in $iconfile)
{
if($icon.extension -eq ".ico")
{
    copy-item $icon.fullname c:\temp\centerlight.ico
       
} 

}

Start-Sleep -seconds 15
$WshShell = New-Object -comObject WScript.Shell

$path = "C:\Users\public\desktop\Centerlight IT Support.lnk"

$targetpath = "C:\ProgramData\bomgar-scc-cb\support.centerlight.org\start.bat"

$iconlocation = "C:\temp\centerlight.ico"

$iconfile = "IconFile=" + $iconlocation

$Shortcut = $WshShell.CreateShortcut($path)
$shortcut.IconLocation = $iconlocation

$Shortcut.TargetPath = $targetpath

$Shortcut.Save()