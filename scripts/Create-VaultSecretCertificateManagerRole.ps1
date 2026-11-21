# Idempotent PowerShell script to create custom role VaultSecretCertificateManager
# Electronics Unlimited Warehouse - Challenge 10

$roleName = "VaultSecretCertificateManager"
$roleDescription = "Allows users to manage Key Vault secrets and certificates"

# Check if role already exists
$existingRole = Get-AzRoleDefinition -Name $roleName -ErrorAction SilentlyContinue

if ($existingRole) {
    Write-Host "Role '$roleName' already exists. Skipping creation." -ForegroundColor Yellow
} else {
    $role = Get-AzRoleDefinition "Key Vault Secrets Officer"
    $role.Id = $null
    $role.Name = $roleName
    $role.Description = $roleDescription
    $role.Actions.Clear()
    $role.NotActions.Clear()
    $role.DataActions.Clear()
    $role.NotDataActions.Clear()
    $role.AssignableScopes.Clear()

    # Control plane
    $role.Actions.Add("Microsoft.KeyVault/vaults/read")

    # Data plane - Secrets
    $role.DataActions.Add("Microsoft.KeyVault/vaults/secrets/read")
    $role.DataActions.Add("Microsoft.KeyVault/vaults/secrets/write")
    $role.DataActions.Add("Microsoft.KeyVault/vaults/secrets/delete")

    # Data plane - Certificates
    $role.DataActions.Add("Microsoft.KeyVault/vaults/certificates/read")
    $role.DataActions.Add("Microsoft.KeyVault/vaults/certificates/write")
    $role.DataActions.Add("Microsoft.KeyVault/vaults/certificates/delete")

    $role.AssignableScopes.Add("/subscriptions/" + (Get-AzContext).Subscription.Id)

    New-AzRoleDefinition -Role $role
    Write-Host "Custom role '$roleName' created successfully." -ForegroundColor Green
}
