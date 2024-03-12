Function Update-resourceTags {
    param(
        [string]$subscriptionId,
        [string]$resourceGroup,
        [hashtable]$tags
    )

 

    # Set the current subscription
    Set-AzContext -Subscription $subscriptionId

 

    # Retrieve Network Interfaces in the specified Resource Group
    $resources = Get-AzResource -ResourceGroupName $resourceGroup

 

    # Iterate through each Network Interface and update tags
    foreach ($resource in $resources) {
        # Merge the existing tags with the new tags, giving priority to the new tags
        $mergedTags = @{}
        if ($resource.Tags) {
            $resource.Tags.GetEnumerator() | ForEach-Object {
                $mergedTags[$_.Key] = $_.Value
            }
        }
        if ($tags) {
            $tags.GetEnumerator() | ForEach-Object {
                $mergedTags[$_.Key] = $_.Value
            }
        }

 

        # Update tags for the Network Interface
        Update-AzTag -ResourceId $resource.Id -Tag $mergedTags -Operation Merge
    }
}

 

# Authenticate using Service Principal
$clientId = "xxxxxxxxxxxxxxxxxxxxxxxx"
$clientSecret = "xxxxxxxxxxx"
$tenantId = "xxxxxxxxxxxxxxxx"
$securePassword = ConvertTo-SecureString -AsPlainText $clientSecret -Force
$psCredential = New-Object System.Management.Automation.PSCredential($clientId, $securePassword)
Connect-AzAccount -ServicePrincipal -Credential $psCredential -TenantId $tenantId

 

# Read Excel data and update tags for network interfaces
$excelFilePath = "C:\Excel-File-path.xlsx"
$excelData = Import-Excel -Path $excelFilePath

 

foreach ($row in $excelData) {
    $resourceGroup = $row.Resource_Group
    $subscriptionName = $row.Subscription_Name
    #tags based on your requirement in excel sheet    
    $tags = @{
        "CostCenter" = $row.CostCenter
        "AppOwner" = $row.AppOwner
        "AssetOwner" = $row.AssetOwner
        "ServiceNowBA" = $row.ServiceNowBA
        "ServiceNowAS" = $row.ServiceNowAS
        "SecurityReviewID" = $row.SecurityReviewID
    }

 

    # Get the subscription ID based on subscription name
    $subscriptionId = (Get-AzSubscription | Where-Object { $_.Name -eq $subscriptionName }).Id

 

    # Update tags for Network Interfaces in the Resource Group without removing existing tags
    Update-resourceTags -subscriptionId $subscriptionId -resourceGroup $resourceGroup -tags $tags
}