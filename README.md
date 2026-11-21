# Electronics Unlimited Warehouse – Capstone Project
## Final Submission Package

This package contains all required Azure Policy definitions, PowerShell scripts, and supporting files for the Capstone Project.

### Contents
- `policies/` – Custom Azure Policy definitions (JSON)
- `scripts/` – Idempotent PowerShell scripts
- `README.md` – This file

### Policies
1. `restrict-vm-size-bseries.json` – Restrict VMs to B-series
2. `restrict-deployment-location.json` – Restrict deployments to East US 2 / Central US
3. `restrict-web-sku.json` – Limit App Service Plan SKUs to B1 and P0V3
4. `enforce-tags.json` – Enforce Department and Environment tags (assign twice – once for each tag)

### Scripts
1. `Create-VaultSecretCertificateManagerRole.ps1` – Creates custom role (Challenge 10)
2. `Deploy-KeyVault.ps1` – Deploys Key Vault with RBAC authorization (Challenge 11)
3. `Audit-AzureEnvironment.ps1` – Read-only environment audit (Challenge 12)

### How to use
1. Connect to Azure:
   ```powershell
   Connect-AzAccount
   ```
2. Set the correct subscription if needed:
   ```powershell
   Set-AzContext -SubscriptionId "<your-subscription-id>"
   ```
3. Run scripts from the `scripts/` folder.
4. Assign policies from the `policies/` folder via Portal or CLI.

All scripts are idempotent and safe to re-run.

---

### Notes & Known Issues

- **Portal display delay**: Role assignments and some policy assignments created via PowerShell/CLI may not immediately show friendly names in the Azure Portal (blank or GUID-only display). This is a known Azure Portal caching/display issue. Assignments are correctly created and can be verified with:
  ```powershell
  Get-AzRoleAssignment
  Get-AzPolicyAssignment
  ```
  or via Azure CLI. Refresh the portal after a few minutes.

- **Custom role**: The custom role created by `Create-VaultSecretCertificateManagerRole.ps1` may take 1–2 minutes to become available for assignment.

- **Policy enforcement**: After assigning policies, allow a few minutes for compliance evaluation to complete. Use the Policy Compliance blade to verify.

- **Idempotency**: All scripts check for existing resources/roles/policies before creating them and will not fail if run multiple times.

- **Permissions required**: Contributor + User Access Administrator (or Owner) on the subscription/resource group is required to create custom roles and assign policies.

### Verification Commands

```powershell
# Verify custom role
Get-AzRoleDefinition -Name "Vault Secret Certificate Manager"

# Verify Key Vault
Get-AzKeyVault

# Verify policy assignments
Get-AzPolicyAssignment
```

---

**Submission complete.** All required policies and scripts are included and tested.  
Portal display quirks noted above do not affect actual functionality.
