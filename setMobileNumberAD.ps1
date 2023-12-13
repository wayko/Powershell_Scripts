$CSVData = Import-Csv -Path c:\temp\edison-test.csv

 

If ((Get-Module).Name -notcontains "ActiveDirectory") {Import-Module ActiveDirectory}

 

$Users = Get-ADUser -Filter * -Properties EmailAddress

 

Foreach ($Line in $CSVData) {

 

    $Email = $Line.Email

 

    $Username = ($Users | Where {$_.EmailAddress -eq $Email}).SamAccountName

 

    $Params = @{

 

        Identity = $Username

 

        Mobile = $Line.Mobile

 

    }

 

    If ($Username) {Set-ADUser @Params; Write-Host "Set new phone info for $Username"}

 

    Else {Write-Warning "No user found for email $Email"}

 

}