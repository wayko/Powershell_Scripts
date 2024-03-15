$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://0013100excc01/Powershell/" 
Import-PSSession $session -DisableNameChecking -AllowClobber



#. 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'
#Connect-ExchangeServer -auto

$password = "xrD~da3=47vOk5Hd=pZ^"
$securePassword =  ConvertTo-SecureString $password -AsPlainText -Force

$LogFolder = "D:\ExchangeMailboxCreation\Logs_Kinship"
$LogFile = $LogFolder + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log"

Function Write-Log
{
    param 
    (
    [Parameter(Mandatory=$True)]
    [array]$LogOutput,
    [Parameter(Mandatory=$True)]
    [string]$Path
    )
    $currentDate = (Get-Date -UFormat "%d-%m-%Y")
    $currentTime = (Get-Date -UFormat "%T")
    $logOutput = $logOutput -join (" ")
    "[$currentDate $currentTime] $logOutput" | Out-File $Path -Append
}

function generateEmailAlias($samAccountName) 
{
    $user = get-aduser $samAccountName
    $allemails = $(Get-ADUser -Filter * -Properties "EmailAddress").EmailAddress
    $iteration = 1
    write-host $iteration
    $unique = $false
    $emailAlias = ""

    while($unique -eq $false) 
    {
        $temp = $($user.GivenName.substring(0,$iteration).tolower()) + $($user.Surname.tolower()) -replace '\s+', ''

        if($allemails -notcontains $($temp + "@kinshiphs.com")) 
        {
            $emailAlias = $temp
            $unique = $true
        } 
        else 
        {
            $iteration++
        }
    }
    return $emailAlias
}

$allusers = get-aduser -Filter * -SearchBase "OU=users,OU=Kinship,DC=Centerlight,DC=cl,DC=local" -Properties "EmailAddress","whenCreated","EmployeeID"



$newusers = $allusers | ? { $_.whenCreated -gt (Get-Date ).AddDays(-1) }

if($newusers.count -or $newusers.count -eq 0) 
{
    Write-Log -LogOutput "$($newusers.count) user accounts created in the last day" -Path $LogFile
} 
else 
{
    Write-Log -LogOutput "1 user account created in the last day" -Path $LogFile
}

foreach($user in $newusers) 
{
    $employeeID = $user.EmployeeID
    $userMemberships = Get-ADUser $user.SamAccountName -Properties "memberOf","title"
    if($userMemberships.MemberOf -notcontains "CN=DELG-G-O365E3,OU=Groups,OU=Centerlight,DC=Centerlight,DC=CL,DC=LOCAL" -or $userMemberships.MemberOf -notcontains "CN=DELG-G-O365Kiosk,OU=Groups,OU=Centerlight,DC=Centerlight,DC=CL,DC=LOCAL") 
    {
        if($userMemberships.title -contains "MAINTENANCE MECHANIC" -or $userMemberships.title -eq "TRADES HELPER") 
        {
            Write-Log -LogOutput "$($user.samaccountname) is being added to the O365 Kiosk group" -Path $LogFile
            Add-ADGroupMember -Identity DELG-G-O365Kiosk -Members $user.samaccountname
        } 
        else 
        {
            Write-Log -LogOutput "$($user.samaccountname) is being added to the O365 E3 group" -Path $LogFile
            Add-ADGroupMember -Identity DELG-G-O365E3 -Members $user.samaccountname
        } 
    }
       
    if($user.UserPrincipalName -notmatch "@kinshiphs.com") 
    {
        Write-Log -LogOutput "$($user.samaccountname) is licensed, but needs an email address" -Path $LogFile

        $emailalias = generateEmailAlias($user.SamAccountName) #get the username as jsmith or jasmith depending on number users with same name.
        $centerlightEmail = $emailalias + "@centerlight.org"   #create centerlight email
        $kinshipEmail = $emailalias + "@kinshiphs.com" #set kinship email as a variable
        $employeeEmail = $employeeID + "@kinshiphs.com"
        #Check if user's samaccount name is not the same as email alias (jsmith)#
        if ($user.SamAccountName -ne $emailalias) 
        {
        Set-ADUser $user.SamAccountName -Replace @{samaccountname=$employeeID}#it will set the samaccount name#
        Set-ADUser $employeeID -Replace @{UserPrincipalName=$employeeEmail} #set user principalname to kinship email
        Set-ADUser $employeeID -Replace @{mail=$kinshipEmail} #set user mail field to kinship email
        }    
        Write-Log -LogOutput "$($emailAlias) alias has been generated - $emailalias" -Path $LogFile


       try
       {
            
            #setup remote mailbox
            enable-remotemailbox $user.Name -remoteroutingaddress "$emailAlias@centerlight.mail.onmicrosoft.com" -PrimarySmtpAddress $kinshipEmail -Alias $emailalias 
            
            #Set-ADUser $user.SamAccountName -Replace @{samaccountname="107347"}       
        }
        catch
        {
            Write-host -ForegroundColor DarkRed "Encountered Error:"$_.Exception.Message

             #$SmtpServer = 'smtpserver'
             #$SmtpUser = 'user'
             #$smtpPassword = 'paswword'
             #$MailtTo = 'email'
             #$Mailbcc = 'email'
             #$MailFrom = 'email'
             #$MailSubject = "There are file/s in $directory" 
             #$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force) 
             #$portNumber =587
             #Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -SmtpServer $SmtpServer -UseSsl -Credential $Credentials -port $portNumber 
          
        }
        
    }
    else 
    {
        Write-Log -LogOutput "$($emailalias) is licensed and already has an email address" -Path $LogFile
        write-host "$user.samaccountname already has a mailbox"
    }

       
} 

Remove-PSSession $session 