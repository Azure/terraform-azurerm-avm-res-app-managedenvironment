# java_components submodule

Manages a Java managed component (Eureka Server, Spring Cloud Config, etc.) for a Container Apps Managed Environment.

```hcl
module "java_components" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/java_components"
  version   = "<version>"

  name           = "eureka"
  parent_id      = "/subscriptions/.../managedEnvironments/my-env"
  component_type = "SpringCloudEureka"
  configurations = []
  ingress        = {}
  scale          = {}
  service_binds  = []
}
```
