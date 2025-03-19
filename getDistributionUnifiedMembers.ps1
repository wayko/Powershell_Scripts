Connect-ExchangeOnline -UserPrincipalName administration@gracehcs.com
$DistributionGroups = Get-DistributionGroup
$csvUnifiFile =  
$csvDistributionFile = 

foreach($groups in $DistributionGroups)
{
     $groups.name | Tee-Object C:\users\skomsul\Desktop\distrbutiongroup.csv -Append
     Get-DistributionGroupMember -identity $groups.Name |Select-Object name| Tee-Object $csvDistributionFile -Append
}



$unifidgroups = Get-UnifiedGroup | Sort-Object Name

foreach($members in $unifidgroups)
{

 $memberName = $members | Get-UnifiedGroupLinks -LinkType Members | select displayName

 $memberName
}
   "Group Name" | Tee-Object -Append
   $members.Name | Tee-Object $csvUnifiFile -Append
   "ManagedBy" | Tee-Object $csvUnifiFile -Append
   $members.ManagedBy | Tee-Object $csvUnifiFile -Append
   "Members" | Tee-Object $csvUnifiFile -Append
   $memberName = $members | Get-UnifiedGroupLinks -LinkType Members | select-object Name 
   $memberName |Tee-Object $csvUnifiFile -Append
   "NextUnifiedGroup" | Tee-Object $csvUnifiFile -Append
   " " |  Tee-Object $csvUnifiFile -Append
}