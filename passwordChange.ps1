Connect-MsolService

Get-MsolUser -All | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true