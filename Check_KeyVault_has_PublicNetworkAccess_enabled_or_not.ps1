Connect-AzAccount

# Set paths to your CSV file and output text file
$csvPath = "C:\Excl-filepath.xlsx"
$outputPath = "C:\Excel-file-path.xlsx"

# Open output file
$outputFile = New-Object System.IO.StreamWriter $outputPath -ErrorAction SilentlyContinue

# Loop through each Key Vault
foreach ($keyVault in Import-Csv $csvPath) {
  # Get Key Vault name and subscription
  $vaultName = $keyVault.KeyVault_Name
  $subscriptionName = $keyVault.Subscription_Name

  # Set subscription context
  Set-AzContext -SubscriptionName $subscriptionName

  $vaultId = (Get-AzKeyVault -VaultName $vaultName).ResourceId

  # Check Public Firewall status
  try {
    $keyVault = Get-AzKeyVault -VaultName $vaultName
    $PublicNetworkAccess = $keyVault.PublicNetworkAccess
    $PublicNetworkAccessStatus = if ($PublicNetworkAccess) { "Enabled" } else { "Disabled" }

    Write-Host "Public Network Access for '$vaultName': $PublicNetworkAccessStatus"
    $outputFile.WriteLine("$vaultName ($subscriptionName) - Public Network Access: $PublicNetworkAccessStatus")
  } catch {
    Write-Host "Error checking Public Ntwork Access for '$vaultName': $_"
    $outputFile.WriteLine("$vaultName ($subscriptionName) - Error checking Public Network Access")
  }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
