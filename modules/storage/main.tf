resource "azapi_resource" "this" {
  type = "Microsoft.App/managedEnvironments/storages@2024-03-01"
  body = {
    properties = {
      azureFile = {
        accessMode  = var.access_mode
        accountKey  = var.access_key
        accountName = var.account_name
        shareName   = var.share_name
      }
    }
  }
  name                      = var.name
  parent_id                 = var.managed_environment.resource_id
  schema_validation_enabled = true

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
