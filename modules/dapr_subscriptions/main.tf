resource "azapi_resource" "this" {
  name                 = var.name
  parent_id            = var.parent_id
  type                 = var.resource_types.app_managed_environments_dapr_subscriptions
  body                 = local.resource_body
  ignore_body_changes  = length(var.ignore_body_changes.app_managed_environments_dapr_subscriptions) > 0 ? var.ignore_body_changes.app_managed_environments_dapr_subscriptions : null
  ignore_null_property = true
  replace_triggers_refs = [
    "properties.pubsubName",
    "properties.topic",
  ]
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
