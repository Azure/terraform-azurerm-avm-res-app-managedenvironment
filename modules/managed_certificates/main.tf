resource "azapi_resource" "this" {
  location            = var.location
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.app_managed_environments_managed_certificates
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.app_managed_environments_managed_certificates) > 0 ? var.ignore_body_changes.app_managed_environments_managed_certificates : null
  replace_triggers_refs = [
    "properties.subjectName",
    "properties.domainControlValidation",
  ]
  response_export_values = [
    "properties.error",
    "properties.validationToken",
  ]
  retry = var.retry
  tags  = var.tags

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
