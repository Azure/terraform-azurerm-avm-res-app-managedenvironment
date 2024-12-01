module "storage" {
  source   = "./modules/storage"
  for_each = var.storages

  name                = each.key
  managed_environment = { resource_id = azapi_resource.this_environment.id }

  access_key   = each.value.access_key
  account_name = each.value.account_name
  share_name   = each.value.share_name
  access_mode  = each.value.access_mode

  timeouts = each.value.timeouts
}
