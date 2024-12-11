Connect-MgGraph -Scopes Group.Read.All, GroupMember.Read.All, User.Read.All, Files.Read.All, PeopleSettings.Read.All,PeopleSettings.ReadWrite.All -NoWelcome

$params = @{
	directoryPropertyName = "CustomAttribute1"
	annotations = @(
		@{
			displayName = "Extension"
		}
	)
}


$params3 = @{
	directoryPropertyName = "CustomAttribute10"
	annotations = @(
		@{
			displayName = "Initials"
		}
	)
}


$params2 = @{
	name = "userExtension"
	dataType = "String"
	isMultiValued = $false
	targetObjects = @(
		"User"
	)
}

New-MgAdminPeopleProfileCardProperty -BodyParameter $params3

get-mgadminpeopleprofilecardproperty -all


Get-MgAdminPeople

Get-MgAdminPeopleProfileCardProperty -ProfileCardPropertyId "CustomAttribute10"
Get-MgApplicationExtensionProperty -ApplicationId "f74aea15-e81a-4d45-ad04-d5780d591398" -ExtensionPropertyId "b91ce874-139c-4fa4-a834-b7887f8153db"

Get-MgApplication -ApplicationId "f74aea15-e81a-4d45-ad04-d5780d591398"

New-MgApplicationExtensionProperty -ApplicationId "f74aea15-e81a-4d45-ad04-d5780d591398" -BodyParameter $params2


#Get-MgUser -all


#Get-MgUserChatMessageHostedContentCount


#Import-Module Microsoft.Graph.People

#get-mguserprofileaddress -userid 77b4cb84-ede2-4f3d-8731-f296192c77b4

