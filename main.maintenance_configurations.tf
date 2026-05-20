module "maintenance_configurations" {
  source   = "./modules/maintenance_configurations"
  for_each = var.maintenance_configurations

  name              = each.value.name
  parent_id         = azapi_resource.this_environment.id
  scheduled_entries = each.value.scheduled_entries
  enable_telemetry  = var.enable_telemetry
}
