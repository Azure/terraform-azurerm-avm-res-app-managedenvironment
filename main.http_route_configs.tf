module "http_route_configs" {
  source   = "./modules/http_route_configs"
  for_each = var.http_route_configs

  location            = var.location
  name                = each.value.name
  parent_id           = azapi_resource.this.id
  custom_domains      = each.value.custom_domains
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.app_managed_environments_http_route_configs
  resource_types      = var.resource_types.app_managed_environments_http_route_configs
  retry               = var.retry
  rules               = each.value.rules
  timeouts            = var.timeouts
}
