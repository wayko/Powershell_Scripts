Install-Module -Name ImportExcel


$Folders = Get-ChildItem -Path f:\Test -Recurse -Directory
$secondFolder = Get-ChildItem -Path g:\test -Recurse
$Report = @()

foreach($folder in $Folders)
{
   $Acl = (Get-Acl -Path $Folder.FullName).Access | Select @{Name="Path";Expression={Convert-Path $folder.FullName}},IdentityReference,FileSystemRights |Export-excel -Path f:\exceltest\fileperm.xlsx -WorksheetName $folder.Name -Append   
}
