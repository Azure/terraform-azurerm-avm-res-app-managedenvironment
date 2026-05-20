# managed_certificates submodule

Manages Azure-managed TLS certificates for a Container Apps Managed Environment custom domain.

```hcl
module "managed_certificates" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/managed_certificates"
  version   = "<version>"

  name         = "my-managed-cert"
  parent_id    = "/subscriptions/.../managedEnvironments/my-env"
  location     = "australiaeast"
  subject_name = "myapp.example.com"
}
```
