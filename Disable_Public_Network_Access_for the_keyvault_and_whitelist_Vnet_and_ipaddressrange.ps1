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

    # Check Public Network Access status
    try {
        $keyVault = Get-AzKeyVault -VaultName $vaultName
        $publicNetworkAccessEnabled = $keyVault.PublicNetworkAccess

        Write-Host $publicNetworkAccessEnabled
        
        if ($publicNetworkAccessEnabled) {
            
            

            # Add virtual network rule (Replace with your specific parameters)
            
            $subnetId = @("subnet-resource-id-1","subnet-resource-id-2")
            $ipAddressesrange = @("199.204.156.0/22","198.27.9.0/24")

            try {
                Write-Host "Adding virtual network rule for '$vaultName'"
                $outputFile.WriteLine("$vaultName ($subscriptionName) - Adding virtual network rule")

                Add-AzKeyVaultNetworkRule -VaultName  $keyVault.VaultName -IpAddressRange $ipAddressesrange -VirtualNetworkResourceId $subnetId -PassThru
                Write-Host "Disabling Public Network Access for '$vaultName'"
                $outputFile.WriteLine("$vaultName ($subscriptionName) - Disabling Public Network Access")

            # Disable Public Network Access
                Update-AzKeyVaultNetworkRuleSet -InputObject $keyVault -DefaultAction Deny -Bypass AzureServices
            } catch {
                Write-Host "Error adding virtual network rule: $_"
                $outputFile.WriteLine("$vaultName ($subscriptionName) - Error adding virtual network rule: $($_)")
            }
        } else {
            Write-Host "Public Network Access for '$vaultName': Already disabled"
            $outputFile.WriteLine("$vaultName ($subscriptionName) - Public Network Access: Already disabled")
        }
    } catch {
        Write-Host "Error checking or handling Public Network Access for '$vaultName': $_"
        $outputFile.WriteLine("$vaultName ($subscriptionName) - Error checking or handling Public Network Access: $($_)")
    }
}

# Close output file
$outputFile.Close()

Write-Host "Information written to file: $outputPath"
