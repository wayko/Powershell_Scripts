Get-Content $env:UserProfile”\AppData\Roaming\Microsoft\Teams\settings.json” | ConvertFrom-Json | Select Version, Ring, Environment

Install-Module -Name UcLobbyTeams

$teamsversion = get-ucteamsversion

foreach($version in $teamsversion)
{


    if ($version.Version -eq '23335.230.2636.4249')
    {
        write-host "New Version Of Teams"
    }
}