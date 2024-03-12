Connect-AzAccount

# Set path to your CSV file and output text file
$csvPath = "C:\Excel-file-path.csv"
$outputPath = "C:\Excel-file-path.txt"

# Log Analytics workspace details
$logAnalyticsWorkspaceId = "Log-analytics-Workspace-id"
$logAnalyticsWorkspaceName = "Log-Analytics-Workspace-Name"

# Read CSV data
$loadbalancers = Import-Csv $csvPath

# Open output file
$outputFile = New-Object System.IO.StreamWriter $outputPath -ErrorAction SilentlyContinue

# Loop through each Load Balancer
foreach ($loadbalancer in $loadbalancers) {
  # Get Key Vault name and subscription
  $loadbalancerName = $loadbalancer.loadbalancer_Name
  $subscriptionName = $loadbalancer.Subscription_Name
  $ResourceGroup = $loadbalancer.ResourceGroup

  # Set subscription context
  Set-AzContext -Subscription $subscriptionName

  $loadbalancerId = (Get-AzLoadBalancer -Name $loadbalancerName -ResourceGroupName $ResourceGroup).Id

  # Check if diagnostic setting exists
  $diagnosticSetting = Get-AzDiagnosticSetting -ResourceId $loadbalancerId

  # Create diagnostic setting if not present
  if (!$diagnosticSetting) {
    Write-Host "Creating diagnostic setting for '$loadbalancerName'..."
    try {
      # Define categories to collect (modify as needed)
      $categories = New-AzDiagnosticSettingLogSettingsObject -Enabled $true -CategoryGroup allLogs
      $metric = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category AllMetrics

      # Create diagnostic setting
      New-AzDiagnosticSetting -Name diagnostic-alllogs-pd1cloudsiem -ResourceId $loadbalancerId -WorkspaceId $logAnalyticsWorkspaceId -Log $categories -Metric $metric
      Write-Host "Diagnostic setting created successfully."
    } catch {
      Write-Host "Error creating diagnostic setting: $_"
      $outputFile.WriteLine("$loadbalancerName ($subscriptionName) - Error creating diagnostic setting")
    }
  } else {
    Write-Host "Diagnostic setting already exists for '$loadbalancerName'."
  }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
