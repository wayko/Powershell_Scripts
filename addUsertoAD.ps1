# Function to generate a random password
function Generate-RandomPassword {
    $length = 12 # Set the desired password length
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+"
    -join ((Get-Random -Count $length -InputObject $chars.ToCharArray()) -join '')
}

# Import CSV and create users with randomized passwords
Import-CSV -Path "C:\temp\import.csv" | ForEach-Object {
    $randomPassword = Generate-RandomPassword
    
    # Create the 'Name' by combining first name and last name
    $fullName = "$($_.givenName) $($_.sn)"
    
    New-ADUser `
        -Name $fullName `
        -SamAccountName $_.sAMAccountName `
        -UserPrincipalName $_.userPrincipalName `
        -GivenName $_.givenName `
        -Surname $_.sn `
        -DisplayName $_.displayName `
        -EmailAddress $_.mail `
        -OfficePhone $_.telephoneNumber `
        -Title $_.title `
        -Department $_.department `
        -Manager $_.manager `
        -Description $_.description `
        -Path $_.ou `
        -AccountPassword (ConvertTo-SecureString $randomPassword -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true

    # Optionally, log the username and password to a file (ensure this file is secured)
    "$($_.sAMAccountName), $randomPassword" | Out-File -Append -FilePath "C:\temp\passwords.csv"
}