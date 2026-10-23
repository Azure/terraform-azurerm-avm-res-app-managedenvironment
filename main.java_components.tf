module "java_components" {
  source   = "./modules/java_components"
  for_each = var.java_components

  component_type      = each.value.component_type
  location            = var.location
  name                = each.value.name
  parent_id           = azapi_resource.this.id
  configurations      = each.value.configurations
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.app_managed_environments_java_components
  ingress             = each.value.ingress
  resource_types      = var.resource_types.app_managed_environments_java_components
  retry               = var.retry
  scale               = each.value.scale
  service_binds       = each.value.service_binds
  timeouts            = var.timeouts
}
