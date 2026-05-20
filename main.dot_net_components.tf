module "dot_net_components" {
  source   = "./modules/dot_net_components"
  for_each = var.dot_net_components

  name             = each.value.name
  parent_id        = azapi_resource.this_environment.id
  component_type   = each.value.component_type
  configurations   = each.value.configurations
  enable_telemetry = var.enable_telemetry
  service_binds    = each.value.service_binds
}
