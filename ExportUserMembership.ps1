# Connect to Azure AD
Connect-AzureAD

# Ensure ImportExcel module is available
Import-Module ImportExcel

# Set output path
$outputFile = "C:\Users\Ashraf Shaikh\Documents\MultipleGroupUsers.xlsx"

# Initialize results array
$results = @()

# Get all Azure AD users
$allUsers = Get-AzureADUser -All $true

Write-Host "Total users found: $($allUsers.Count)"
Write-Host "Processing users who are members of multiple groups..."

# Loop through users
foreach ($user in $allUsers) {
    # Get group memberships
    $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object { $_.ObjectType -eq "Group" }

    if ($groups.Count -gt 1) {
        # Get unique group names
        $groupNames = $groups | Select-Object -ExpandProperty DisplayName -Unique
        $groupList = $groupNames -join ", "

        # Add record to result
        $results += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            DisplayName       = $user.DisplayName
            Department        = $user.Department
            GroupNames        = $groupList
        }
    }
}

# Export to Excel in Documents folder
$results | Export-Excel -Path $outputFile -WorksheetName "MultipleGroupUsers" -AutoSize -TableName "UsersWithGroups"

Write-Host "`n✅ Excel export completed!"
Write-Host "📁 Saved to: $outputFile"
