# A script to copy Prosystem Engagement backup file to the J:\Backups folders

# Set Source and Destination Path, and setting for date
$GetEDrive = Get-PSDrive G
$src = "E:\SQL Backup"
$dst = "\\winshares\J_DRIVE\Backups\TB-SQL"
$Max_days = "-1"
$Curr_date = get-date
$Purge = "-5"

#Checking date and then copying file from Seagate backup drive to the backup folder on the J drive
Foreach($file in (Get-ChildItem $src))
{
    if($file.LastWriteTime -gt ($Curr_date).adddays($Max_days))
    {
        Copy-Item -Path $file.fullname -Destination $dst
        
    }


}

Foreach($file2 in (Get-ChildItem $dst))
{
    if($file2.LastWriteTime -lt ($Curr_date).adddays($Purge))
    {
        remove-Item -Path $file2.fullname 
        
    }


}
 
#Created on January 27 2016 Rev 1
#Modified on April 12th 2016

