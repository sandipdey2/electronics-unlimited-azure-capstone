# Idempotent PowerShell script to deploy Key Vault
# Electronics Unlimited Warehouse - Challenge 11

$resourceGroupName = "rg-shared-vault"
$location = "eastus2"
$vaultName = "kv-devshared-" + (Get-Date -Format "yyyyMMdd") + "eu"

# Ensure resource group exists
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag @{Environment="Dev"; Department="Engineering"}
}

# Create or update Key Vault with RBAC
$vault = Get-AzKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue

if (-not $vault) {
    New-AzKeyVault -Name $vaultName -ResourceGroupName $resourceGroupName -Location $location `
        -EnableRbacAuthorization -Tag @{Environment="Dev"; Department="Engineering"}
    Write-Host "Key Vault $vaultName created." -ForegroundColor Green
} else {
    Update-AzKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -EnableRbacAuthorization $true
    Write-Host "Key Vault $vaultName already exists and RBAC enabled." -ForegroundColor Yellow
}
