Connect-ExchangeOnline -UserPrincipalName administration@gracehcs.com

Get-DistributionGroupMember -Identity "staffing c fairlawn"

Remove-DistributionGroupMember -Identity "staffing c fairlawn" -member "Pat Banta"