# Azure Environment Discovery / Audit Script
# Electronics Unlimited Warehouse - Challenge 12
# Read-only, safe for production

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Azure Environment Discovery / Audit" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Current context
$context = Get-AzContext
Write-Host "Current Subscription: $($context.Subscription.Name)" -ForegroundColor White
Write-Host "Signed-in Account: $($context.Account.Id)" -ForegroundColor White
Write-Host ""

# Accessible subscriptions
try {
    $subscriptions = Get-AzSubscription -ErrorAction Stop
} catch {
    Write-Warning "Limited permissions. Using current subscription only."
    $subscriptions = @($context.Subscription)
}

$subscriptions | Format-Table Name, Id, State -AutoSize

$allResourceGroups = @()
$allResources = @()

foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)" -ForegroundColor Yellow
    try {
        Set-AzContext -SubscriptionId $sub.Id -ErrorAction Stop | Out-Null
        $rgs = Get-AzResourceGroup -ErrorAction Stop
        $allResourceGroups += $rgs
        $resources = Get-AzResource -ErrorAction Stop
        $allResources += $resources
    } catch {
        Write-Warning "Access denied to subscription $($sub.Name). Skipping."
    }
}

Write-Host "`n=== Resource Groups ===" -ForegroundColor Cyan
$allResourceGroups | Select-Object @{N='Subscription';E={$_.SubscriptionId}}, ResourceGroupName, Location, ProvisioningState | Format-Table -AutoSize

Write-Host "`n=== Resources ===" -ForegroundColor Cyan
$allResources | Select-Object @{N='Subscription';E={$_.SubscriptionId}}, Name, ResourceType, ResourceGroupName, Location | Format-Table -AutoSize

# Categorize
$vms = $allResources | Where-Object { $_.ResourceType -eq "Microsoft.Compute/virtualMachines" }
$vnets = $allResources | Where-Object { $_.ResourceType -eq "Microsoft.Network/virtualNetworks" }
$nics = $allResources | Where-Object { $_.ResourceType -eq "Microsoft.Network/networkInterfaces" }
$nsgs = $allResources | Where-Object { $_.ResourceType -eq "Microsoft.Network/networkSecurityGroups" }
$pips = $allResources | Where-Object { $_.ResourceType -eq "Microsoft.Network/publicIPAddresses" }

if ($vms) { Write-Host "`nVirtual Machines ($($vms.Count))" -ForegroundColor Green; $vms | Format-Table Name, ResourceGroupName, Location }
if ($vnets) { Write-Host "`nVirtual Networks ($($vnets.Count))" -ForegroundColor Green; $vnets | Format-Table Name, ResourceGroupName, Location }
if ($nics) { Write-Host "`nNetwork Interfaces ($($nics.Count))" -ForegroundColor Green; $nics | Format-Table Name, ResourceGroupName, Location }
if ($nsgs) { Write-Host "`nNetwork Security Groups ($($nsgs.Count))" -ForegroundColor Green; $nsgs | Format-Table Name, ResourceGroupName, Location }
if ($pips) { Write-Host "`nPublic IP Addresses ($($pips.Count))" -ForegroundColor Green; $pips | Format-Table Name, ResourceGroupName, Location }

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Accessible Subscriptions: $($subscriptions.Count)"
Write-Host "Resource Groups: $($allResourceGroups.Count)"
Write-Host "Total Resources: $($allResources.Count)"
Write-Host "VMs: $($vms.Count) | VNets: $($vnets.Count) | NICs: $($nics.Count) | NSGs: $($nsgs.Count) | Public IPs: $($pips.Count)"
Write-Host "Completed: $(Get-Date)" -ForegroundColor Gray
