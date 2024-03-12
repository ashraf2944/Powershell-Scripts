Connect-AzAccount

# Set paths to your CSV file and output text file
$csvPath = "C:\Excel-file-path.csv"
$outputPath = "C:\Excel-file-path.txt"

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

  # Check purge protection status
  try {
    $keyVault = Get-AzKeyVault -VaultName $vaultName
    $purgeProtection = $keyVault.EnablePurgeProtection
    $purgeStatus = if ($purgeProtection) { "True" } else { "False" }

    Write-Host "Purge protection for '$vaultName': $purgeStatus"
    $outputFile.WriteLine("$vaultName ($subscriptionName) - Purge Protection: $purgeStatus")
  } catch {
    Write-Host "Error checking purge protection for '$vaultName': $_"
    $outputFile.WriteLine("$vaultName ($subscriptionName) - Error checking purge protection")
  }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
