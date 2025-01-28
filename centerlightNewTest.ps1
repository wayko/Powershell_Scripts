$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://0013100excc01/Powershell/" 
Import-PSSession $session -DisableNameChecking -AllowClobber

$password = "xrD~da3=47vOk5Hd=pZ^"
$securePassword =  ConvertTo-SecureString $password -AsPlainText -Force

$LogFolder = "D:\ExchangeMailboxCreation\Logs_matterofcare"
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
    $user = get-aduser $samAccountName -Server 001100SADC01
    $allemails = $(Get-ADUser -Filter * -Properties "EmailAddress" -Server 001100SADC01).EmailAddress
    $iteration = 1
    write-host $iteration
    $unique = $false
    $emailAlias = ""

    while($unique -eq $false) 
    {
        $temp = $($user.GivenName.substring(0,$iteration).tolower()) + $($user.Surname.tolower()) -replace '\s+', ''

        if($allemails -notcontains $($temp + "@matterofcare.org")) 
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

#Get all users created in last 24 hours and get the count of users
$newusers = Get-ADUser -Filter * -SearchBase "OU=users,OU=matterofcare,DC=Centerlight,DC=cl,DC=local" -server 001100SADC01  -Properties "cn", "EmailAddress", "whenCreated", "EmployeeID" | Where-Object {$_.whenCreated -ge (Get-Date).AddDays(-1)} 

$totalUsers=($newusers |Measure-Object).count

if($totalUsers -ge 1) 
{
    Write-Log -LogOutput "$($totalUsers) user(s) account(s) created in the past 24 hours." -Path $LogFile
    Write-host "$($totalUsers) user(s) account(s) created in the past 24 hours."
} 
else 
{
    Write-Log -LogOutput "Zero(0) user(s) account(s) have been created in the past 24 hours." -Path $LogFile
    Write-host "Zero(0) user(s) account(s) have been created in the past 24 hours."
}

foreach($user in $newusers) 
{
 
    $employeeID = $user.EmployeeID
    $userMemberships = Get-ADUser $user.SamAccountName -Server 001100SADC01 -Properties "memberOf","title"
    if($userMemberships.MemberOf -notcontains "CN=DELG-G-O365E3,OU=Groups,OU=Centerlight,DC=Centerlight,DC=CL,DC=LOCAL" -or $userMemberships.MemberOf -notcontains "CN=DELG-G-O365Kiosk,OU=Groups,OU=Centerlight,DC=Centerlight,DC=CL,DC=LOCAL") 
    {
        if($userMemberships.title -contains "MAINTENANCE MECHANIC" -or $userMemberships.title -eq "TRADES HELPER") 
        {
            Write-Log -LogOutput "$($user.samaccountname) is being added to the O365 Kiosk group" -Path $LogFile
            Write-host "$($user.samaccountname) is being added to the O365 Kiosk group"
            Add-ADGroupMember -Identity DELG-G-O365Kiosk -Members $user.samaccountname -Server 001100SADC01
        } 
        else 
        {
            Write-Log -LogOutput "$($user.samaccountname) is being added to the O365 E3 group" -Path $LogFile
            Write-host "$($user.samaccountname) is being added to the O365 E3 group"
            Add-ADGroupMember -Identity DELG-G-O365E3 -Members $user.samaccountname -Server 001100SADC01
        } 
    }
       
    if($user.UserPrincipalName -notmatch "@matterofcare.org") 
    {
        Write-Log -LogOutput "$($user.samaccountname) is licensed, but needs an email address" -Path $LogFile
        write-host "$($user.samaccountname) is licensed, but needs an email address"
        $emailalias = generateEmailAlias($user.SamAccountName) #get the username as jsmith or jasmith depending on number users with same name.
        $centerlightEmail = $emailalias + "@centerlight.org"   #create centerlight email
        $matterofcareEmail = $emailalias + "@matterofcare.org" #set matterofcare email as a variable
        $employeeEmail = $employeeID + "@matterofcare.org"
        
        #Check if user's samaccount name is not the same as email alias (jsmith)#
        if (($user.SamAccountName).ToLower() -ne ($emailalias).ToLower()) 
        {
            Write-Log -LogOutput "$($emailAlias) alias has not been generated - $emailalias" -Path $LogFile
            write-host "$($emailAlias) alias has not been generated - $emailalias"
        } 
        else
        {   
        Set-ADUser -Server 001100SADC01 $user.SamAccountName -Replace @{samaccountname=$employeeID}#it will set the samaccount name#
        Set-ADUser -Server 001100SADC01 $employeeID -Replace @{UserPrincipalName=$employeeEmail} #set user principalname to matterofcare email
        Set-ADUser -Server 001100SADC01 $employeeID -Replace @{mail=$matterofcareEmail} #set user mail field to matterofcare email
        Write-Log -LogOutput "$($emailAlias) alias has been generated - $emailalias" -Path $LogFile
            write-host "$($emailAlias) alias has been generated - $emailalias"
        }
       try
       {
            
            #setup remote mailbox
            enable-remotemailbox $user.Name -remoteroutingaddress "$emailAlias@centerlight.mail.onmicrosoft.com" -PrimarySmtpAddress $matterofcareEmail -Alias $emailalias 
               
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