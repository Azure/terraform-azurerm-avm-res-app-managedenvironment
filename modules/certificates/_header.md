# certificates submodule

Manages TLS/SSL certificates for a Container Apps Managed Environment.

```hcl
module "certificates" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/certificates"
  version   = "<version>"

  name      = "my-cert"
  parent_id = "/subscriptions/.../managedEnvironments/my-env"
  location  = "australiaeast"

  certificate_key_vault_properties = {
    key_vault_url = "https://my-kv.vault.azure.net/certificates/my-cert"
    identity      = "/subscriptions/.../userAssignedIdentities/my-identity"
  }
}
```
