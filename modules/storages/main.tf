resource "azapi_resource" "this" {
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.app_managed_environments_storages
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.app_managed_environments_storages) > 0 ? var.ignore_body_changes.app_managed_environments_storages : null
  replace_triggers_refs = [
    "properties.azureFile.accountName",
    "properties.azureFile.shareName",
    "properties.nfsAzureFile.server",
  ]
  response_export_values = [
  ]
  retry = var.retry
  sensitive_body = {
    properties = {
      azureFile = var.azure_file == null ? null : {
        accountKey = var.account_key
      }
    }
  }
  sensitive_body_version = {
    "properties.azureFile.accountKey" = var.account_key_version
  }

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
