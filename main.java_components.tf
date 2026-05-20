module "java_components" {
  source   = "./modules/java_components"
  for_each = var.java_components

  component_type   = each.value.component_type
  name             = each.value.name
  parent_id        = azapi_resource.this_environment.id
  configurations   = each.value.configurations
  enable_telemetry = var.enable_telemetry
  ingress          = each.value.ingress
  scale            = each.value.scale
  service_binds    = each.value.service_binds
}
