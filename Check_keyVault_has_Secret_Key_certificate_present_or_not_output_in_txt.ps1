# Connect to Azure
Connect-AzAccount

# Load Excel sheet with Key Vault information
$keyVaultsInfo = Import-Csv -Path "C:\excel-file-path.csv"

# Text file path for storing empty vaults
$outputFilePath = "C:\empty_keyvaults.txt"

# Clear the existing file contents
Clear-Content -Path $outputFilePath

# Loop through each Key Vault
foreach ($keyVault in $keyVaultsInfo) {
    # Set subscription and Key Vault name
    $subscriptionName = $keyVault.Subscription_Name
    $keyVaultName = $keyVault.KeyVault_Name

    # Connect to the specified subscription
    Set-AzContext -Subscription $subscriptionName

    # Check for secrets, keys, and certificates
    $hasSecrets = (Get-AzKeyVaultSecret -VaultName $keyVaultName).Count -gt 0
    $hasKeys = (Get-AzKeyVaultKey -VaultName $keyVaultName).Count -gt 0
    $hasCertificates = (Get-AzKeyVaultCertificate -VaultName $keyVaultName).Count -gt 0

    # Check if all types are empty
    if (!$hasSecrets -and !$hasKeys -and !$hasCertificates) {
        # Write empty vault details to the text file
        Add-Content -Path $outputFilePath -Value "$subscriptionName, $keyVaultName"
    }
}

Write-Host "Empty Key Vault details written to: $outputFilePath"
