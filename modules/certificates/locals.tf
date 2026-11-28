locals {
  resource_body = {
    name = var.name
    properties = {
      certificateKeyVaultProperties = var.certificate_key_vault_properties == null ? null : {
        identity    = var.certificate_key_vault_properties.identity
        keyVaultUrl = var.certificate_key_vault_properties.key_vault_url
      }
    }
  }
}
