resource "azapi_resource" "this" {
  type = "Microsoft.App/managedEnvironments/daprComponents@2024-03-01"
  body = {
    properties = {
      componentType        = var.component_type
      ignoreErrors         = var.ignore_errors
      initTimeout          = var.init_timeout
      secretStoreComponent = var.secret_store_component
      scopes               = var.scopes
      version              = var.dapr_component_version

      metadata = var.metadata != null ? [
        for m in var.metadata : {
          name      = m.name
          secretRef = m.secret_name
          value     = m.value
        }
      ] : null

      secrets = var.secret != null ? [
        for s in var.secret : {
          # identity    = s.identity
          # keyVaultUrl = s.key_vault_secret_id
          name  = s.name
          value = s.value
        }
      ] : null
    }
  }
  name      = var.name
  parent_id = var.managed_environment.resource_id

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}
