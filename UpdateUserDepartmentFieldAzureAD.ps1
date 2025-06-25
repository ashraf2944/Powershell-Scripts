

# Load required modules
Import-Module AzureAD
Import-Module ImportExcel

# Connect to Azure AD
Connect-AzureAD

# Path to your Excel file
$excelFile = "C:\Users\Ashraf Shaikh\Documents\AllUserGroupMemberships.xlsx"

# Import all users from Excel
$users = Import-Excel -Path $excelFile

foreach ($user in $users) {
    $upn = $user.UserPrincipalName
    $newDept = $user.Department

    if (-not $upn -or -not $newDept) {
        Write-Warning "Skipping entry with missing UPN or Department."
        continue
    }

    try {
        # Get user from Azure AD
        $aadUser = Get-AzureADUser -ObjectId $upn

        if ($aadUser.Department -ne $newDept) {
            Write-Output "🔄 Updating Department for $upn from '$($aadUser.Department)' to '$newDept'..."
            Set-AzureADUser -ObjectId $upn -Department $newDept
            Write-Output "✅ Department updated for $upn."
        } else {
            Write-Output "ℹ️ No update needed for $upn — already in '$newDept'."
        }
    } catch {
        Write-Warning "❌ Error processing $upn: $_"
    }
}
