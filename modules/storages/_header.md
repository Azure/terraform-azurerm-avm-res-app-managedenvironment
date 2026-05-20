# storages submodule

Manages an Azure Files storage mount for a Container Apps Managed Environment.

```hcl
module "storages" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/storages"
  version   = "<version>"

  name      = "my-storage"
  parent_id = "/subscriptions/.../managedEnvironments/my-env"
  azure_file = {
    access_mode  = "ReadWrite"
    account_name = "mystorageaccount"
    share_name   = "myshare"
  }
  nfs_azure_file = {}
}
```
