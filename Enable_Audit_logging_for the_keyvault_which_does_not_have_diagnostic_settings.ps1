Connect-AzAccount

# Set paths to your CSV file and output text file
$csvPath = "C:\Excel-file-path.csv"
$outputPath = "C:\Excel-file-path.txt"

# Log Analytics workspace details
$logAnalyticsWorkspaceId = "Log-analytics-workspace-id"
$logAnalyticsWorkspaceName = "Log-Analytics-workspace-Name"

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

  # Create diagnostic setting if not present
  if (!$diagnosticSetting) {
    Write-Host "Creating diagnostic setting for '$vaultName'..."
    try {
      # Define categories to collect (modify as needed)
      $categories = New-AzDiagnosticSettingLogSettingsObject -Enabled $true -CategoryGroup audit

      # Create diagnostic setting
      New-AzDiagnosticSetting -Name diagnostic-alllogs-pd1cloudsiem -ResourceId $vaultId -WorkspaceId $logAnalyticsWorkspaceId -Log $categories
      Write-Host "Diagnostic setting created successfully."
    } catch {
      Write-Host "Error creating diagnostic setting: $_"
      $outputFile.WriteLine("$vaultName ($subscriptionName) - Error creating diagnostic setting")
    }
  } else {
    Write-Host "Diagnostic setting already exists for '$vaultName'."
  }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
