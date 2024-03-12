Function Update-AppInsightsTags {
    param(
        [string]$subscriptionId,
        [string]$resourceGroup,
        [string]$appInsightsName
    )

    # Set the current subscription
    Set-AzContext -Subscription $subscriptionId

    # Retrieve Resource Group tags
    $resourceGroupTags = (Get-AzResourceGroup -Name $resourceGroup).Tags

    # Retrieve Application Insights resource
    $appInsights = Get-AzApplicationInsights -ResourceGroupName $resourceGroup -Name $appInsightsName

    # Print appInsights.Tags for debugging
    Write-Output "AppInsights Tags: $($appInsights.Tags)"

    # Initialize empty hashtable for missing tags
    $missingTags = @{}

    # Add all resource group tags (skipping existing tag check)
    foreach ($tag in $resourceGroupTags.GetEnumerator()) {
        $missingTags[$tag.Key] = $tag.Value
    }

    # Update tags for Application Insights if there are missing tags
    if ($missingTags.Count -gt 0) {
        Update-AzTag -ResourceId $appInsights.Id -Tag $missingTags -Operation Merge
        Write-Output "Added " ($missingTags.Count) " missing tags to Application Insights."
    } else {
        Write-Output "No missing tags found. Application Insights already has all resource group tags."
    }
}

# Authenticate using Service Principal (replace with your credentials)
$clientId = "xxxxxxxxxxxxxxxxxxxxxxxx"
$clientSecret = "xxxxxxxxxxx"
$tenantId = "xxxxxxxxxxxxxxxx"
$securePassword = ConvertTo-SecureString -AsPlainText $clientSecret -Force
$psCredential = New-Object System.Management.Automation.PSCredential($clientId, $securePassword)
Connect-AzAccount -ServicePrincipal -Credential $psCredential -TenantId $tenantId

# Read Excel data and update tags for Application Insights
$excelFilePath = "C:\Excel-file-path.xlsx"
$excelData = Import-Excel -Path $excelFilePath

foreach ($row in $excelData) {
    $resourceGroup = $row.RESOURCE_GROUPS
    $subscriptionName = $row.SUBSCRIPTION
    $appInsightsName = $row.AppName

    # Get the subscription ID based on subscription name
    $subscriptionId = (Get-AzSubscription | Where-Object { $_.Name -eq $subscriptionName }).Id

    # Update tags for Application Insights in the Resource Group
    Update-AppInsightsTags -subscriptionId $subscriptionId -resourceGroup $resourceGroup -appInsightsName $appInsightsName
}
