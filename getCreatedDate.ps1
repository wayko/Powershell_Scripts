$created = Get-ADUser -Filter * -Properties Created | Select-Object Name,Created | Sort-Object Created
foreach($object in $created){
$object
}