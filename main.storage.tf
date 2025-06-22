module "storage" {
  source   = "./modules/storage"
  for_each = var.storages

  access_key          = each.value.access_key
  account_name        = each.value.account_name
  managed_environment = { resource_id = azapi_resource.this_environment.id }
  name                = each.key
  share_name          = each.value.share_name
  access_mode         = each.value.access_mode
  timeouts            = each.value.timeouts
}
