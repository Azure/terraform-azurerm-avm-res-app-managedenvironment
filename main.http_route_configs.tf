module "http_route_configs" {
  source   = "./modules/http_route_configs"
  for_each = var.http_route_configs

  name             = each.value.name
  parent_id        = azapi_resource.this_environment.id
  custom_domains   = each.value.custom_domains
  enable_telemetry = var.enable_telemetry
  rules            = each.value.rules
}
