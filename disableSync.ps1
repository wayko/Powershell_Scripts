Connect-MsolService
 Set-MsolDirSyncEnabled -EnableDirSync $false
 (Get-MSOLCompanyInformation).DirectorySynchronizationEnabled
 Set-MsolDirSyncEnabled -EnableDirSync $true