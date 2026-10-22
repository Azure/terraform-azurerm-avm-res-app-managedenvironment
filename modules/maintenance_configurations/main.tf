resource "azapi_resource" "this" {
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.app_managed_environments_maintenance_configurations
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.app_managed_environments_maintenance_configurations) > 0 ? var.ignore_body_changes.app_managed_environments_maintenance_configurations : null
  response_export_values = [
  ]
  retry = var.retry

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
