module "maintenance_configurations" {
  source   = "./modules/maintenance_configurations"
  for_each = var.maintenance_configurations

  location            = var.location
  name                = each.value.name
  parent_id           = azapi_resource.this.id
  scheduled_entries   = each.value.scheduled_entries
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.app_managed_environments_maintenance_configurations
  resource_types      = var.resource_types.app_managed_environments_maintenance_configurations
  retry               = var.retry
  timeouts            = var.timeouts
}
