Import-Module Microsoft.Graph.Users

$chadAdmin = '8d87e7da-51be-460a-9a50-214e61480170'
$chad = '77b4cb84-ede2-4f3d-8731-f296192c77b4'
$atoadmin = '5a243f98-bce5-4563-bbc2-91dc27eaf716'

Find-MgGraphCommand -command Get-MgUser | Select -First 1 -ExpandProperty Permissions


Connect-MgGraph -Scopes "Application.ReadWrite.All", "DelegatedPermissionGrant.ReadWrite.All"

Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" -Property Oauth2PermissionScopes | Select -ExpandProperty Oauth2PermissionScopes | fl 


Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All" -NoWelcome

Connect-MgGraph -Scopes "Directory.ReadWrite.All" -NoWelcome


Get-MgContext | Select-Object -ExpandProperty Scopes


get-mgusermanager -UserId '8d87e7da-51be-460a-9a50-214e61480170'

Get-mguser -UserId  $chadAdmin

Connect-AzureAD

Get-AzureADApplication | format-table 

Get-AzureADApplication | Get-AzureADApplicationExtensionProperty

New-AzureADApplication -DisplayName "Test Graph App"

$params = @{
	body = @{
		content = "Hello all testing Microsoft Graph Please disregard"
	}
}

New-MgTeamChannelMessage -TeamId $teamId -ChannelId $channelId -BodyParameter $params


$userId = "5a243f98-bce5-4563-bbc2-91dc27eaf716"

$params = @{
	extension_6843e5657218416b8698e395735216bc_testString = "Testing"
}

Update-MgUser -UserId 'atlanticadmin@maillie.com' -AdditionalProperties $params

Update-MgUserExtension -UserId $userId -ExtensionId "a001bf56-b901-455c-ab36-533f95f262ae" -WhatIf

Get-MgDirectoryObjectAvailableExtensionProperty | where Name -match "testString"
 -
'Get-MgDirectoryObject -DirectoryObjectId "a001bf56-b901-455c-ab36-533f95f262ae"