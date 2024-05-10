resource "azapi_resource" "dapr_components" {
  for_each = var.dapr_components

  type = "Microsoft.App/managedEnvironments/daprComponents@2023-05-01"
  body = {
    properties = {
      componentType        = each.value.component_type
      ignoreErrors         = each.value.ignore_errors
      initTimeout          = each.value.init_timeout
      secretStoreComponent = each.value.secret_store_component
      scopes               = each.value.scopes
      version              = each.value.version

      metadata = each.value.metadata != null ? [
        for m in each.value.metadata : {
          name      = m.name
          secretRef = m.secret_name
          value     = m.value
        }
      ] : null

      secrets = each.value.secret != null ? [
        for s in each.value.secret : {
          identity    = s.identity
          keyVaultUrl = s.key_vault_secret_id
          name        = s.name
          value       = s.value
        }
      ] : null
    }
  }
  name                      = each.key
  parent_id                 = azapi_resource.this_environment.id
  schema_validation_enabled = true

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}
