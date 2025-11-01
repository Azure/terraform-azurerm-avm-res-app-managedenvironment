resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.managed_environment.resource_id
  type      = "Microsoft.App/managedEnvironments/certificates@2025-01-01"
  body = {
    properties = local.certificate_properties
  }
  schema_validation_enabled = false
  sensitive_body = {
    properties = local.certificate_sensitive_properties
  }
  tags = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

locals {
  # Non-sensitive properties
  certificate_properties = var.key_vault_url != null ? {
    certificateKeyVaultProperties = {
      identity    = var.key_vault_identity
      keyVaultUrl = var.key_vault_url
    }
  } : {}
  # Sensitive properties - password and value
  certificate_sensitive_properties = var.key_vault_url == null ? {
    password = var.certificate_password
    value    = var.certificate_value
  } : {}
}
