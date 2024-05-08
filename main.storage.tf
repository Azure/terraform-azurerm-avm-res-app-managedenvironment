resource "azapi_resource" "storages" {
  for_each = var.storages

  type = "Microsoft.App/managedEnvironments/storages@2023-05-01"
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
  name      = each.key
  parent_id = azapi_resource.this_environment.id

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}
