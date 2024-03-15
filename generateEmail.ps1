. 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'
Connect-ExchangeServer -auto

$LogFolder = "D:\ExchangeMailboxCreation\Logs_Kinship"
$LogFile = $LogFolder + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log"

Function Write-Log
{
	param (
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

function generateEmailAlias($samAccountName) {
    $user = get-aduser $samAccountName
    $allemails = $(Get-ADUser -Filter * -Properties "EmailAddress").EmailAddress
    $iteration = 1
    $unique = $false
    $emailAlias = ""

    while($unique -eq $false) {
        $temp = $($user.GivenName.substring(0,$iteration).tolower()) + $($user.Surname.tolower()) -replace '\s+', ''

        if($allemails -notcontains $($temp + "@kinshiphs.com")) {
            $emailAlias = $temp
            $unique = $true
        } else {
            $iteration++
        }
    }
    return $emailAlias
}

$allusers = get-aduser -Filter * -SearchBase "OU=users,OU=Kinship,DC=Centerlight,DC=cl,DC=local" -Properties "EmailAddress","whenCreated"

$newusers = $allusers | ? { $_.whenCreated -gt (Get-Date ).AddDays(-1) }

if($newusers.count -or $newusers.count -eq 0) {
    Write-Log -LogOutput "$($newusers.count) user accounts created in the last day" -Path $LogFile
} else {
    Write-Log -LogOutput "1 user account created in the last day" -Path $LogFile
}

foreach($user in $newusers) {
    $userMemberships = Get-ADUser $user.SamAccountName -Properties "memberOf","title"
   if($userMemberships.MemberOf -contains "CN=DELG-G-O365E3,OU=Groups,OU=Centerlight,DC=Centerlight,DC=CL,DC=LOCAL" `
         -or $userMemberships.MemberOf -contains "CN=DELG-G-O365Kiosk,OU=Groups,OU=Centerlight,DC=Centerlight,DC=CL,DC=LOCAL") {
        
        if($user.EmailAddress -notmatch "@kinshiphs.com") {
            Write-Log -LogOutput "$($user.samaccountname) is licensed, but needs an email address" -Path $LogFile

            $emailalias = generateEmailAlias($user.SamAccountName)
            Write-Log -LogOutput "$($user.samaccountname) alias has been generated - $emailalias" -Path $LogFile
            
            enable-remotemailbox $user.samaccountname -remoteroutingaddress $($emailAlias + "@centerlight.mail.onmicrosoft.com") -alias $emailAlias
        } else {
            Write-Log -LogOutput "$($user.samaccountname) is licensed and already has an email address" -Path $LogFile
        }
    } else {
        Write-Log -LogOutput "$($user.samaccountname) is not licensed" -Path $LogFile
        if($userMemberships.title -contains "MAINTENANCE MECHANIC" -or `
           $userMemberships.title -eq "TRADES HELPER"
        ) {
            Write-Log -LogOutput "$($user.samaccountname) is being added to the O365 Kiosk group" -Path $LogFile
            Add-ADGroupMember -Identity DELG-G-O365Kiosk -Members $user.samaccountname
        } else {
            Write-Log -LogOutput "$($user.samaccountname) is being added to the O365 E3 group" -Path $LogFile
            Add-ADGroupMember -Identity DELG-G-O365E3 -Members $user.samaccountname
        }
    }
}
