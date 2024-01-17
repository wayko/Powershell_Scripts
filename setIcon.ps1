$iconfile = get-childitem F:\iconchange 

foreach($icon in $iconfile)
{
if($icon.extension -eq ".ico")
{
    rename-item -path $icon.fullname -NewName "f:\iconchange\centericon.ico"
    $icon.name
} 

}