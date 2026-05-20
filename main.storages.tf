module "storages" {
  source   = "./modules/storages"
  for_each = var.storages

  name                = each.value.name
  parent_id           = azapi_resource.this_environment.id
  account_key         = each.value.account_key
  account_key_version = each.value.account_key_version
  azure_file          = each.value.azure_file
  enable_telemetry    = var.enable_telemetry
  nfs_azure_file      = each.value.nfs_azure_file
}
