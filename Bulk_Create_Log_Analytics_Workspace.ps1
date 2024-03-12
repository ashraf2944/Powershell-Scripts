Connect-AzAccount


# Read data from Excel sheet (replace file path and sheet name)
$ExcelFile = "C:\Excel_file_path.xlsx"
$ExcelData = Import-Excel -Path $ExcelFile -WorksheetName "Your-Worksheet-Name" | Select-Object "ResourceGroupName", "Location", "SubscriptionId", "LogAnalyticsWorkspaceName"



# Iterate through each row and create workspace
foreach ($row in $ExcelData) {
    $ResourceGroupName = $row.ResourceGroupName
    $Location = $row.Location
    $SubscriptionId = $row.SubscriptionId
    $LogAnalyticsWorkspaceName = $row.LogAnalyticsWorkspaceName
Set-AzContext -Subscription $SubscriptionId

$resourcegrouptags = Get-AzResourceGroup -Name $ResourceGroupName
 
# Initialize an empty hashtable
$tagHashtable = @{}

# Extract the tags and their values
foreach ($tag in $resourcegrouptags.Tags.GetEnumerator()) {
$tagHashtable[$tag.Name] = $tag.Value
}
 # Create workspace
New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Location $Location -Name $LogAnalyticsWorkspaceName -Tag $tagHashtable

Write-Host "Workspace '$LogAnalyticsWorkspaceName' created successfully."

}

Write-Host "Script execution completed."
