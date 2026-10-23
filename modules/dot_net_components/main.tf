resource "azapi_resource" "this" {
  name                  = var.name
  parent_id             = var.parent_id
  type                  = var.resource_types.app_managed_environments_dot_net_components
  body                  = local.resource_body
  ignore_body_changes   = length(var.ignore_body_changes.app_managed_environments_dot_net_components) > 0 ? var.ignore_body_changes.app_managed_environments_dot_net_components : null
  replace_triggers_refs = ["properties.componentType"]
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
