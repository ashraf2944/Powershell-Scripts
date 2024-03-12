Connect-AzAccount


# Set path to Excel sheet
$excelFilePath = "C:\Excel-file-path.xlsx"

# Read data from Excel sheet, ensuring SubscriptionId is included
$appInsightsData = Import-Excel -Path $excelFilePath -WorksheetName "Sheet-Name" | Select-Object ClassicApplicationInsightName, SubscriptionId, ResourceGroupName, "LogAnalyticsWorkspaceResourceId"

# Iterate through each Application Insights entry
foreach ($entry in $appInsightsData) {
    # Set variables for clarity
    $classicName = $entry.ClassicApplicationInsightName
    $subscription = $entry.SubscriptionId
    $resourceGroup = $entry.ResourceGroupName
    $workspaceId = $entry.LogAnalyticsWorkspaceResourceId

    Set-AzContext -Subscription $subscription

    # Validate input data
    if ($classicName -eq $null -or $subscription -eq $null -or $resourceGroup -eq $null -or $workspaceId -eq $null) {
        Write-Error "Missing required data for '$classicName'. Please check your Excel sheet."
        continue
    }

    # Get classic Application Insights resource
    $classicAppInsights = Get-AzApplicationInsights -Name $classicName -ResourceGroupName $resourceGroup

    if ($classicAppInsights) {
        # Check if already migrated to Workspace-based
        if ($classicAppInsights.IngestionMode -eq "LogAnalytics") {
            Write-Output "Application Insights '$classicName' is already migrated to Workspace-based."
            continue
        }

        # Perform migration using Update-AzApplicationInsights
        try {
            # Retrieve the current Application Insights component
            $appInsights = Get-AzApplicationInsights -Name $classicAppInsights.Name -ResourceGroupName $classicAppInsights.ResourceGroupName
 
            # Initialize an empty hashtable
            $tagHashtable = @{}
 
            # Extract the tags and their values
            foreach ($tag in $appInsights.Tag.AdditionalProperties.GetEnumerator()) {
            $tagHashtable[$tag.Key] = $tag.Value
            }
 

            Update-AzApplicationInsights -Name $classicAppInsights.Name -ResourceGroupName $classicAppInsights.ResourceGroupName -IngestionMode "LogAnalytics" -WorkspaceResourceId $workspaceId -Tag $tagHashtable
            Write-Output "Application Insights '$classicName' successfully migrated to Workspace-based."
        } catch {
            Write-Error "Error migrating '$classicName': $_"
        }
    } else {
        Write-Warning "Classic Application Insights '$classicName' not found."
    }
}

# Disconnect from Azure (optional)
Disconnect-AzAccount
