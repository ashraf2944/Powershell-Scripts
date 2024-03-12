Connect-AzAccount

# Set path to your CSV file and output text file
$csvPath = "C:\Excel-File-path.xlsx"
$outputPath = "C:\Excel-File-Path.xlsx"

# Read CSV data
$keyVaults = Import-Csv $csvPath

# Open output file
$outputFile = New-Object System.IO.StreamWriter $outputPath -ErrorAction SilentlyContinue

# Loop through each Key Vault
foreach ($keyVault in $keyVaults) {
  # Get Key Vault name and subscription
  $vaultName = $keyVault.KeyVault_Name
  $subscriptionName = $keyVault.Subscription_Name

  # Set subscription context
  Set-AzContext -Subscription $subscriptionName

  $vaultId = (Get-AzKeyVault -VaultName $vaultName).ResourceId

  # Check if diagnostic setting exists
  $diagnosticSetting = Get-AzDiagnosticSetting -ResourceId $vaultId

  # Check if diagnostics are enabled
  if (!$diagnosticSetting) {
    # Write details to output file
    $outputFile.WriteLine("$vaultName ($subscriptionName)")
  }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
