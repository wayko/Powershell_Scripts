 $url  = "https://api.itglue.com/"
 Add-ITGlueBaseURI -base_uri $url 
 $APIKEy = "ITG.915b5d1866e89be87b762c8562f06dca.LxjuSDNVg5mgBD8AJiy7VUwgDf00hO_VrVWphHnGzR80dGKlPxbufISsiH965NFE"
 Add-ITGlueAPIKey -Api_Key $APIKEy
 
 
 $allID  = Import-Csv csvfile
 
 foreach($OrgID in $allID)
 {
 
 

 $DeleteOrg1 =@{ 
        type = 'organizations'
        attributes = @{
        id = $OrgID.ID
        }
         
        }

Remove-ITGlueOrganizations -filter_id $OrgID.ID -data $DeleteOrg1
}

#Get-ITGlueOrganizations -filter_id $OrgID | select-object links
 
 $configID = Get-ITGlueConfigurations -page_size 1000 -filter_organization_id $OrgID.id

 foreach($id in $configID)
 {

    foreach($ids in $id.data.id)
    {
       $DeleteOrg =@{ 
        type = 'configurations'
        attributes = @{
            id = $ids
        }
    }

        try
        {
        Remove-ITGlueConfigurations -filter_organization_id $OrgID.id -data $DeleteOrg
        }
        catch 
        {

        }

    }
    
 }
 
 $DeleteOrg1 =@{ 
        type = 'organizations'
        attributes = @{
        id = "1840595"
        }
         
        }

Remove-ITGlueOrganizations -filter_id '1840595' -data $DeleteOrg1

get-help Remove-ITGlueConfiguations

update-help

$ContactList = (Get-ITGlueContacts -page_size 1000 -organization_id $OrgID.id).data
foreach ($contactToDelete in $contactList) {
    
     $DeleteContact = @{
            "type" = "contacts"
            "attributes" = @{
                "id" = [int64]$contactToDelete.Id
            }
          }

    Remove-ITGlueContacts -filter_organization_id $OrgID.id -data $DeleteContact
       
}


#Get-ITGlueOrganizations -filter_name "Awisco"

#$configuration = Get-ITGlueConfigurations -filter_organization_id "1273235" -page_size 1000

#foreach($device in $configuration)
#{
  #  $attribute = $device.data | Select-Object attributes

    
#}
#foreach($item in $attribute)
#{
 #   $item.attributes | export-csv f:\devices.csv -NoTypeInformation -Append
#}