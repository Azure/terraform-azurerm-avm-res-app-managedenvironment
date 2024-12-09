# Azure Container Apps Managed Environment Dapr Components Module

This module is used to create Dapr Components for a Container Apps Environment.

## Usage

```terraform
module "avm-res-app-managedenvironment-daprcomponent" {
  source = "Azure/avm-res-app-managedenvironment/azurerm//modules/dapr_component"

  managed_environment = {
    resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.App/managedEnvironments/myEnv"
  }

  component_type = "state.azure.blobstorage"
  version        = "v1"
}
```
