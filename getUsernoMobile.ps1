$Users = Get-ADUser -LDAPFilter "(&(!Mobile=*))" |Select-Object Name | Tee-Object c:\noMobile.csv
$Users