#You will need EXO V2 Module: https://docs.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps
Import-Module ExchangeOnlineManagement
Connect-IPPSSession -UserPrincipalName email
$Report = [System.Collections.Generic.List[Object]]::new() 
$Policies = (Get-RetentionCompliancePolicy  -DistributionDetail )
ForEach ($P in $Policies) {
        If ($P.SharePointLocation.Name -eq "All") {
            $ReportLine = [PSCustomObject]@{
              PolicyName = $P.Name
              SiteName   = "All SharePoint Sites"
              SiteURL    = "All SharePoint Sites" }
            $Report.Add($ReportLine) } 
            If ($P.SharePointLocationException -ne $Null) {
               $Locations = ($P | Select -ExpandProperty SharePointLocationException)
               ForEach ($L in $Locations) {
                  $Exception = "*Exclude* " + $L.DisplayName
                  $ReportLine = [PSCustomObject]@{
                    PolicyName = $P.Name
                    SiteName   = $Exception
                    SiteURL    = $L.Name }
               $Report.($ReportLine) }
        }
        ElseIf ($P.SharePointLocation.Name -ne "All") {
           $Locations = ($P | Select -ExpandProperty SharePointLocation)
           ForEach ($L in $Locations) {
               $ReportLine = [PSCustomObject]@{
                  PolicyName = $P.Name
                  SiteName   = $L.DisplayName
                  SiteURL    = $L.Name }
               $Report.Add($ReportLine)  }                    
          }
}
$Report | Sort PolicyName, SiteUrl | Out-GridView
# To export the report
$Report | Export-Csv -NoTypeInformation c:\temp\RetentionSites.csv