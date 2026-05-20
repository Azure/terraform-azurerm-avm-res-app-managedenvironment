# http_route_configs submodule

Manages HTTP routing rules (traffic splitting, path-based routing) for a Container Apps Managed Environment.

```hcl
module "http_route_configs" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/http_route_configs"
  version   = "<version>"

  name           = "my-routes"
  parent_id      = "/subscriptions/.../managedEnvironments/my-env"
  custom_domains = []
  rules          = []
}
```
