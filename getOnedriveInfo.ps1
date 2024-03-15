# Function to get OneDrive item count for a user
function Get-OneDriveItemCount {
    param(
        [string]$userId,
        [string]$accessToken
    )
    $url = "https://graph.microsoft.com/v1.0/users/$userId/drive/root"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{Authorization = "Bearer $accessToken"}
    $itemCount = $response | Select-Object -ExpandProperty folder | Select-Object -ExpandProperty childCount
    return $itemCount
}
 
# Get OneDrive report for all users
$onedriveReport = @()
 
# Get access token
$accessToken = (Get-MgContext).AccessToken
 
# Get all users
$response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users" -Method Get -Headers @{Authorization = "Bearer $accessToken"}
$users = $response.value
 
foreach ($user in $users) {
    $userPrincipalName = $user.UserPrincipalName
    $displayName = $user.DisplayName
 
    # Get OneDrive item count for the user
    $itemCount = Get-OneDriveItemCount -userId $user.id -accessToken $accessToken
 
    # Add user information to the report
    $reportItem = [PSCustomObject]@{
        UserDisplayName = $displayName
        UserPrincipalName = $userPrincipalName
        OneDriveItemCount = $itemCount
    }
 
    $onedriveReport += $reportItem
}
 
# Output the report
$onedriveReport | Format-Table -AutoSize