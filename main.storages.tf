module "storages" {
  source   = "./modules/storages"
  for_each = var.storages

  location            = var.location
  name                = each.value.name
  parent_id           = azapi_resource.this.id
  account_key         = each.value.account_key
  account_key_version = each.value.account_key_version
  azure_file          = each.value.azure_file
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.app_managed_environments_storages
  nfs_azure_file      = each.value.nfs_azure_file
  resource_types      = var.resource_types.app_managed_environments_storages
  retry               = var.retry
  timeouts            = var.timeouts
}
