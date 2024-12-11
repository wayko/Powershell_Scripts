$MailtTo = 'atlanticitsupport@tomorrowsoffice.com'
$MailFrom = 'EDriveMallie@hotmail.com'
$bcc = "jortiz@tomorrowsoffice.com"
$MailSubject = "E drive is not found on TB2022 in Mallie" 



$GetEDrive = Get-PSDrive G
$src = "E:\SQL Backup"
$dst = "C:\Program Files (x86)\Pfx Engagement\Admin\Utilities\Backup Restore"
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