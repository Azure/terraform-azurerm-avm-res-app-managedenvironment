# dapr_components submodule

Manages a Dapr component (state store, pub/sub, binding, etc.) for a Container Apps Managed Environment.

```hcl
module "dapr_components" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/dapr_components"
  version   = "<version>"

  name           = "statestore"
  parent_id      = "/subscriptions/.../managedEnvironments/my-env"
  component_type = "state.azure.blobstorage"
  metadata = [
    { name = "accountName", value = "mystorageaccount" },
    { name = "containerName", value = "state" },
  ]
  secrets = []
}
```
