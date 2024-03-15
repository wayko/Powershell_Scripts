$LocalAppData = [Environment]::GetFolderPath( [Environment+SpecialFolder]::LocalApplicationData )
$ChromeDefaults = Join-Path $LocalAppData "Google\Chrome\User Data\default"
$ChromePrefFile = Join-Path $ChromeDefaults "Preferences"

$Settings = Get-Content $ChromePrefFile | ConvertFrom-Json