Install-Module azuread

Connect-MsolService
Get-MsolUser | Sort-Object -Property Userprincipalname

 Get-MsolDomainFederationSettings -DomainName "ptsamerica.com"

 Set-MsolDomainAuthentication -Authentication Managed -DomainName "ptsamerica.com"

 Convert-MsolDomainToStandard -DomainName "ptsamerica.com"