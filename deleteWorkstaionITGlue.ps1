$url  = "https://api.itglue.com/"
Add-ITGlueBaseURI -base_uri $url 
$APIKEy = "ITG.915b5d1866e89be87b762c8562f06dca.LxjuSDNVg5mgBD8AJiy7VUwgDf00hO_VrVWphHnGzR80dGKlPxbufISsiH965NFE"
Add-ITGlueAPIKey -Api_Key $APIKEy

$configurationId = 104763

$AllClients1 =  Get-ITGlueOrganizations -page_size 1000 -page_number 1


foreach($client in $AllClients1)
{
    foreach($clientID in $client.data)
    {
        #$clientID.id + ":" + $clientID.attributes.name
        
        $configID = Get-ITGlueConfigurations -page_size 1000 -filter_organization_id $clientID.id -filter_configuration_type_id $configurationId

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
                #Delete items in configuration with id 104763 which is the id for Workstation
                try
                {
                    Remove-ITGlueConfigurations -filter_organization_id $clientID.id -data $DeleteOrg
                    Write-host "Deleting workstaions from " $clientID.attributes.name
                }
                catch 
                {
                    Write-host "No workstaions found in " $clientID.attributes.name
                }
               
            }
        }
    }
}


$AllClients2 =  Get-ITGlueOrganizations -page_size 1000 -page_number 2


foreach($client2 in $AllClients2)
{
    foreach($clientID2 in $client2.data)
    {
        #$clientID2.id + ":" + $clientID2.attributes.name
        
        $configID2 = Get-ITGlueConfigurations -page_size 1000 -filter_organization_id $clientID2.id -filter_configuration_type_id $configurationId

        foreach($id2 in $configID2)
        {
             
                foreach($ids2 in $id2.data.id)
                {
                    $DeleteOrg2 =@{ 
                    type = 'configurations'
                    attributes = @{
                    id = $ids2
                    }
                }

               
                #Delete items in configuration with id 104763 which is the id for Workstation
                try
                {
                    Remove-ITGlueConfigurations -filter_organization_id $clientID2.id -data $DeleteOrg2
                    Write-host "Deleting workstaions from " $clientID2.attributes.name
                }
                catch 
                {
                    Write-host "No workstaions found in " $clientID2.attributes.name
                }
               
            }
        }
    }
}



$AllClientsTest =  Get-ITGlueOrganizations -page_size 1000 -page_number 1

foreach($clientTest in $AllClientsTest)
{
    foreach($clientIDTest in $clientTest.data)
    {
        $configIDTest = Get-ITGlueConfigurations -page_size 1000 -filter_organization_id $clientIDTest.id
foreach($idTest in $configIDTest)
        {
 foreach($itemTest in $idTest.data)
                {
                   $itemsTest = $itemTest.attributes.'configuration-type-id'.ToString()  + ":" + $itemTest.attributes.'configuration-type-name' |Sort-Object $itemsTest
                   
                    $itemsTest | Tee-Object f:\configurationITems.csv  -Append
              }
 }

 }}