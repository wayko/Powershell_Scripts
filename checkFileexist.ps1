$userFolders = Get-ChildItem -path c:\users -Directory -force -ErrorAction SilentlyContinue
$insertFile = 
foreach($user in $userFolders)
{
    $files = Get-ChildItem -path c:\users\$user\appdata\roaming\microsoft\teams\backgrounds\uploads -file -Recurse -ErrorAction SilentlyContinue

    foreach($file in $files)
    {
        if ($file.name -contains "Woodmont-TeamsBackground-202310.jpg" -or $file.Name -contains "Woodmont-TeamsBackground-202310-thumbnail.jpg")
        {
            
            new-item c:\temp\foundbackground.txt -Force
            add-content -path c:\temp\foundbackground.txt -value "Woodmont background image Woodmont-TeamsBackground-202310.jpg exist : $(get-date)"  -PassThru
            $test = Get-Content -path c:\temp\foundbackground.txt
            write-host $test
        }
        else
        {
            write-host "File not found"
        }
    }
    
}