Connect-AzAccount

# Set path to your CSV file and output text file
$csvPath = "C:\Excel-file-path.csv"
$outputPath = "C:\Excel-file-path.txt"

# Read CSV data
$loadbalancers = Import-Csv $csvPath

# Open output file
$outputFile = New-Object System.IO.StreamWriter $outputPath -ErrorAction SilentlyContinue

# Loop through each Key Vault
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

  # Check if diagnostics are enabled
  if (!$diagnosticSetting) {
    # Write details to output file
    $outputFile.WriteLine("$loadbalancerName ($subscriptionName)")
  }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
