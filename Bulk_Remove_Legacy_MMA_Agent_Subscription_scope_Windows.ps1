# Get all Windows VMs in the subscription
Set-AzContext -Subscription sub_evicore_dv1
$vms = Get-AzVM | Where-Object { $_.StorageProfile.OsDisk.OsType -eq "Windows" }

# Initialize output array
$output = @()

foreach ($vm in $vms) {
  # Flag to track presence of both agents
  $hasMMA = $false
  $hasAMA = $false

  # Get extensions for the VM
  $extensions = Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name

  foreach ($extension in $extensions) {
    # Check for MMA extension
    if ($extension.Publisher -eq "Microsoft.EnterpriseCloud.Monitoring" -and $extension.ExtensionType -eq "MicrosoftMonitoringAgent") {
      $hasMMA = $true
    }

    # Check for Azure Monitor Agent (AMA) extension
    if ($extension.Publisher -eq "Microsoft.Azure.Monitor" -and ($extension.ExtensionType -eq "AzureMonitorWindowsAgent" -or $extension.ExtensionType -eq "AzureMonitorLinuxAgent")) {
      $hasAMA = $true
    }
  }

  # Check if both agents are present before adding VM details
  if ($hasMMA -and $hasAMA) {
    $output += [PSCustomObject]@{
      "VM Name" = $vm.Name
      "VM OS" = $vm.StorageProfile.OsDisk.OsType
      "OS Version" = $vm.StorageProfile.ImageReference.Offer
      "VM Resource Group" = $vm.ResourceGroupName
      "VM Location" = $vm.Location
      "Extension Name" = "MMA & AMA"  # Concatenated for clarity
      "VM Resource ID" = $vm.Id
    }
  }
}

# Export the output array to a CSV file (if any VMs found)
if ($output.Count -gt 0) {
  $output | Export-Csv -Path "path_to_excel_file\output_MMA_AMA_Extensions_dv1.csv" -NoTypeInformation
} else {
  Write-Host "No VMs found with both MMA and Azure Monitor Agent extensions."
}

$csvData = Import-Csv -Path "path_to_excel_file\output_MMA_Extension_dv1.csv"
az account set --subscription sub_evicore_dv1
foreach ($row in $csvData) {
    # Extract the details from the CSV row
    $vmResourceId = $row.'VM Resource ID'
    $extensionName = $row.'Extension Name'
 
    # Construct the ID for the extension
    $extensionId = "$vmResourceId/extensions/$extensionName"
 
    # Execute the az command and capture the output
    $output = az vm extension delete --ids $extensionId 2>&1
 
    # Print the output and the resource ID to the console
    Write-Host "$vmResourceId : $output"
 
    # Write the output and the resource ID to a log file
    "$vmResourceId : $output" | Out-File "C:\Users\Ashraf.Shaikh\Documents\log.txt" -Append
}
