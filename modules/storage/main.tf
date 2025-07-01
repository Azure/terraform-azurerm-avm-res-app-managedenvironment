resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.managed_environment.resource_id
  type      = "Microsoft.App/managedEnvironments/storages@2024-03-01"
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

  retry = {
    error_message_regex  = ["ContainerAppEnvironmentDisabled"]
    interval_seconds     = 10
    max_interval_seconds = 300
    multiplier          = 2.0
    randomization_factor = 0.3
  }
}
