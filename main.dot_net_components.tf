module "dot_net_components" {
  source   = "./modules/dot_net_components"
  for_each = var.dot_net_components

  location            = var.location
  name                = each.value.name
  parent_id           = azapi_resource.this.id
  component_type      = each.value.component_type
  configurations      = each.value.configurations
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.app_managed_environments_dot_net_components
  resource_types      = var.resource_types.app_managed_environments_dot_net_components
  retry               = var.retry
  service_binds       = each.value.service_binds
  timeouts            = var.timeouts
}
