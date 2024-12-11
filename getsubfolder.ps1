function Get-FolderWithExclusions {
    param(
        [Parameter()]
        $Path,
        [Parameter()]
        [string[]]
        $FoldersToExclude,
        [Parameter()]
        [string[]]
        $KeywordsToExclude
    )

    write-host $Path
    $folders = Get-ChildItem -Path $Path -Directory  | Where-Object {
        $folder = $_
        write-host $folder.FullName
        $folder.FullName -NotIn $FoldersToExclude -and
        !(($KeywordsToExclude | ForEach-Object {
                    $folder.BaseName -match $_
                }) -contains $true)
    }
    $folders
    $folders | ForEach-Object { 
        Get-FolderWithExclusions -Path $_ -FoldersToExclude $FoldersToExclude -KeywordsToExclude $KeywordsToExclude
    }
}

$omitFolders = 'Admin', 'Cad', '20000-AE'
$omitKeywords = 'proposals'

$folder8 = Get-FolderWithExclusions -Path 'F:\Test' -FoldersToExclude $omitFolders -KeywordsToExclude $omitKeywords

foreach($folder in $folder8)
{
    $folder.fullname
}




$omit = 'Admin'
$omit2 = 'Cad'
$omit3 = "20000-AE"
$omit4 = "Proposal"

$folderTest = 'F:\Test'
$folders2 = Get-ChildItem -Path $folderTest -Directory -Recurse | where-object {($_.FullName -inotmatch $omit2 -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit -and $_.PsIsContainer) -and ($_.FullName -inotmatch $omit3 -and $_.PsIsContainer)-and ($_.FullName -inotmatch $omit4 -and $_.PsIsContainer)} 

foreach($folder in $folders2)
{
    $folder.fullname
}
