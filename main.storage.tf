resource "azapi_resource" "storages" {
  for_each = var.storages

  type      = "Microsoft.App/managedEnvironments/daprComponents@2023-05-01"
  name      = each.key
  parent_id = azapi_resource.this_environment.id
  body = jsonencode({
    properties = {
      azureFile = {
        accessMode  = each.value.access_mode
        accountKey  = each.value.access_key
        accountName = each.value.account_name
        shareName   = each.value.share_name
      }
    }
  })

  dynamic "timeouts" {
    for_each = var.storages.timeouts == null ? [] : [var.storages.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
