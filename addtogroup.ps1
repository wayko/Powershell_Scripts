 Set-MsolUser -UserPrincipalName 'email' -UsageLocation "US"
 Set-MsolUserLicense -UserPrincipalName 'email' -AddLicenses license
 Get-MsolAccountSku
  $role = Get-MsolRole -RoleName “Company Administrator”
  Get-MsolRoleMember -RoleObjectId $role.ObjectId


 Add-MsolRoleMember -RoleName “Company Administrator” –RoleMemberEmailAddress email