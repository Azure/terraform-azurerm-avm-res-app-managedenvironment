# Azure Container Apps Managed Environment Storage Module

This module is used to create storage for a Container Apps Environment.

## Usage

```terraform
module "avm-res-app-managedenvironment-storage" {
  source = "Azure/avm-res-app-managedenvironment/azurerm//modules/storage"

  managed_environment = {
    resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.App/managedEnvironments/myEnv"
  }

  account_name = azurerm_storage_account.this.name
  share_name   = azurerm_storage_share.this.name
  access_key   = azurerm_storage_account.this.primary_access_key
  access_mode  = "ReadOnly"
}
```
