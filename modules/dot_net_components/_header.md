# dot_net_components submodule

Manages a .NET Aspire-compatible component for a Container Apps Managed Environment.

```hcl
module "dot_net_components" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/dot_net_components"
  version   = "<version>"

  name           = "aspire-dashboard"
  parent_id      = "/subscriptions/.../managedEnvironments/my-env"
  component_type = "AspireDashboard"
  configurations = []
  service_binds  = []
}
```
