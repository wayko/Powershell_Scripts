$bomgar = "\\001100atlman02\New_Bomgar\New Bomgar\bomgar-scc-w0fdc30f77yzd6hw7yd1iyi6x877d65hg77yi6ic408c90.exe"

Start-Process $bomgar -ArgumentList "--silent"

$TargetFile = "Centerlight IT Support.lnk"
$shortcutFile = "C:\Users\Public\Desktop\Centerlight IT Support.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$shortcut.TargetPath = $TargetFile
$shortcut.IconLocation = "f:\shortcut-1702585308.ico"
$shortcut.
$shortcut.Save()

$icon = "F:\"
copy-item  $icon -Destination c:\users\Public\desktop


$shell = New-Object -ComObject WScript.Shell
$Location = "C:\Users\public\Desktop"
$shortcut = $shell.CreateShortcut("$Location\shortcut.lnk")
$shortcut.TargetPath = 'C:\Users\Public\Documents\Shortcut'
$shortcut.IconLocation = "shell32.dll,21"
$shortcut.Save()


$WshShell = New-Object -comObject WScript.Shell

$path = "C:\Users\public\desktop\Centerlight IT Support.lnk"

$targetpath = "C:\ProgramData\bomgar-scc-cb\support.centerlight.org\start.bat"

$iconlocation = "C:\ProgramData\bomgar-scc-cb\support.centerlight.org\shortcut-1702585308.ico"

$iconfile = "IconFile=" + $iconlocation

$Shortcut = $WshShell.CreateShortcut($path)
$shortcut.IconLocation = $iconlocation

$Shortcut.TargetPath = $targetpath

$Shortcut.Save()