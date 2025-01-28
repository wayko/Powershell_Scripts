Connect-MgGraph -Scopes Group.Read.All, GroupMember.Read.All,Presence.Read.All -NoWelcome

Connect-Graph -Scopes User.Read","Application.Read.All

Get-MgApplication -ApplicationId "a106a0ce-8d41-4ae0-9616-271a2bd6ea53"

Get-MgServicePrincipal -ServicePrincipalId "a106a0ce-8d41-4ae0-9616-271a2bd6ea53"
Get-MgServicePrincipalDelegatedPermissionClassification -ServicePrincipalId "a106a0ce-8d41-4ae0-9616-271a2bd6ea53"
Get-MgServicePrincipalDelegatedPermissionClassificationCount -ServicePrincipalId "a106a0ce-8d41-4ae0-9616-271a2bd6ea53"
GET https://graph.microsoft.com/v1.0/servicePrincipals(appId='41d7d73f-91cc-49c7-9b11-c657adf34828')?$select=id,appId,displayName,appRoles,oauth2PermissionScopes,resourceSpecificApplicationPermissions

Get-MgGroupAppRoleAssignment -all