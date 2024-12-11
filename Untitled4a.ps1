# This script must be run as an administrator
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
$ErrorActionPreference = "Stop"

[version]$minversion='1.9.0'
[version]$maxversion='1.12.0'
function checkAccetableVersionRange($currentversion)
 {
    if (($currentversion -ge $minversion) -and  ($currentversion -le $maxversion))
    {
        Write-Host "Acceptable Pnp.Powershell module version found."
    }
    else
    {
       throw "Currently installed PnP.PowerShell module version is not compatible. Please uninstall the module and re-run this script"
        Exit 1;
    }
 }

$version = (Get-Module -ListAvailable PnP.PowerShell) | Sort-Object Version -Descending  | Select-Object Version -First 1

if($null -eq $version)
{
	Install-Module -Name PnP.Powershell -RequiredVersion 1.12.0 -force
}
else
{
	checkAccetableVersionRange($version.Version);
}


if (Get-Module -ListAvailable -Name Microsoft.Graph) {
    Write-Host "Microsoft.Graph is already installed."
}
else {
    try {
        Install-Module Microsoft.Graph -Scope AllUsers -force -AllowClobber
    }
    catch [Exception] {
        $_.message
        exit
    }
}

#Initialize the graph as first action to avoid the Microsoft bug
Connect-MgGraph

# Registering the PnP Powershell Module
Register-PnPManagementShellAccess

# Add required assemblies
Add-Type -AssemblyName System.Web, PresentationFramework, PresentationCore

# Set a client client Id
$clientId = "f604535a-e789-4cc7-bb9b-98126af4fc15"

# Set a tenant Id
$tenantId = "3fffbf61-5488-40cf-a239-7a97399718a1"

# Get Auth Code based on params
function Get-AuthCode ($clientId, $tenantId, $scope, $redirectUri) {
    # Random State - state is included in response, if you want to verify response is valid
    $state = Get-Random

    # Encode scope to fit inside query string
    $scopeEncoded = [System.Web.HttpUtility]::UrlEncode($scope)

    # Redirect URI (encode it to fit inside query string)
    $redirectUriEncoded = [System.Web.HttpUtility]::UrlEncode($redirectUri)

    # Construct URI
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUriEncoded&response_mode=query&scope=$scopeEncoded&state=$state&prompt=login"

    # Create Window for User Sign-In
    $windowProperty = @{
        Width  = 500
        Height = 700
    }

    $signInWindow = New-Object System.Windows.Window -Property $windowProperty

    # Create WebBrowser for Window
    $browserProperty = @{
        Width  = 480
        Height = 680
    }

    $signInBrowser = New-Object System.Windows.Controls.WebBrowser -Property $browserProperty

    # Navigate Browser to sign-in page
    $signInBrowser.navigate($uri)

    # Create a condition to check after each page load
    $pageLoaded = {

        # Once a URL contains "code=*", close the Window
        if ($signInBrowser.Source -match "code=[^&]*") {

            # With the form closed and complete with the code, parse the query string

            $urlQueryString = [System.Uri]($signInBrowser.Source).Query
            $script:urlQueryValues = [System.Web.HttpUtility]::ParseQueryString($urlQueryString)

            $signInWindow.Close()

        }
    }

    # Add condition to document completed
    $signInBrowser.Add_LoadCompleted($pageLoaded)

    # Show Window
    $signInWindow.AddChild($signInBrowser)
    $signInWindow.ShowDialog()

    # Extract code from query string
    $authCode = $script:urlQueryValues.GetValues(($script:urlQueryValues.keys | Where-Object { $_ -eq "code" }))


    $authCode
}

# Get Exchange Onlike Auth Code (returned as $authCode)
function Get-ExOAuthCode($tenantId) {

    $redirectUri = "http://localhost:3000/cb-integrations/"
    $scope = "openid profile offline_access User.Read User.Read.All Organization.Read.All Directory.Read.All Organization.ReadWrite.All Directory.ReadWrite.All Directory.AccessAsUser.All Reports.Read.All Policy.Read.All Policy.ReadWrite.ConditionalAccess Mail.Send UserAuthenticationMethod.Read.All AuditLog.Read.All IdentityRiskEvent.Read.All SecurityEvents.ReadWrite.All IdentityRiskyUser.Read.All Policy.ReadWrite.Authorization SharePointTenantSettings.ReadWrite.All"

    $authCode = Get-AuthCode -clientId $clientId -tenantId $tenantId -scope $scope -redirectUri $redirectUri

    if ($authCode) {
        $authCode[1]
    }
    else {
        Write-Error "Unable to obtain Auth Code!"
    }
}

#add permission and apply admin grant for Exchange.Manage
function SetPermissionsWithConsent()
{
    $temp1 =  "AppId eq '"+ $clientId + "'"
    Connect-MgGraph -Scopes "Application.ReadWrite.All", "DelegatedPermissionGrant.ReadWrite.All"
    $sp = Get-MgServicePrincipal -Filter $temp1  | Select-Object id
    $ExoApp = Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'"
    $params2 = @{
        "ClientId" = $($sp.Id)
        "ConsentType" = "AllPrincipals"
        "ResourceId" = $ExoApp.Id
        "Scope" = "Exchange.Manage"
        }

        New-MgOauth2PermissionGrant -BodyParameter $params2 -ErrorAction Stop | Format-List Id, ClientId, ConsentType, ExpiryTime, PrincipalId, ResourceId, Scope

    Disconnect-MgGraph -ErrorAction SilentlyContinue
}

#force disconnect any cached sesisons and ignore any error
function DisconnectGraph()
{
try {
     Disconnect-MgGraph -ErrorAction SilentlyContinue
	}
catch [Exception] {
    $message = $_
    Write-Warning "$message"
	}
}

#add permission and apply admin grant for Exchange.Manage
try {
    DisconnectGraph
    SetPermissionsWithConsent
}
catch [Exception] {
    $message = $_
    if ($message.ToString().ToLower().Contains("permission entry already exists") ) {
        Write-Warning "$message"
      }else{
        Write-Error "$message"
        exit
      }
}

#Generate AuthCode
$exOnlineAuthCode = Get-ExOAuthCode -tenantId $tenantId
@{ exchangeOnlineAuthCode = $exOnlineAuthCode } | ConvertTo-Json
        