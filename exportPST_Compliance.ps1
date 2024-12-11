$email = "josystem@edisonlearning.com"
$password = "Aveeno09!"
$SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
$Credential  = New-Object System.Management.Automation.PSCredential $email,$SecuredPassword
Connect-IPPSSession  -Credential $Credential

Function Get-PST{
Param(
    [Parameter(Mandatory=$True, HelpMessage='Enter the email address that you want to export')]
    $Mailbox,
    [Parameter(Mandatory=$True, HelpMessage='Enter the path where you want to save the PST file. !NO TRAILING BACKSLASH!')]
    $ExportLocation # = ""# you can un-comment the = "" to set a default for this parameter.
)

# Create a search name. You can change this to suit your preference
$SearchName = "$Mailbox PST"

Write-Host "Creating compliance search..."
New-ComplianceSearch -Name $SearchName -ExchangeLocation $Mailbox  -AllowNotFoundExchangeLocationsEnabled $true #Create a content search, including the the entire contents of the user's email and onedrive. If you didn't provide a OneDrive URL, or it wasn't valid, it will be ignored.
Write-Host "Starting compliance search..."
Start-ComplianceSearch -Identity $SearchName #Start the search created above
Write-Host "Waiting for compliance search to complete..."


Write-Host "Compliance search is complete!"
Write-Host "Creating export from the search..."

}


$users = import-csv C:\temp\Users.csv


foreach($user in $users)
{
   $pstFolder = $user.Directory
   $pstFolder
   
   New-Item -path "o:\$pstFolder" -ItemType "directory"
   $path = get-item -path "o:\$pstFolder" 
 
   
   Get-PST $user.Email $path.fullName
   Write-Host "Download Complete!"
}
