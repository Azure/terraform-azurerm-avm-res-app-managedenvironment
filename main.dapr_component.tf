module "dapr_component" {
  source   = "./modules/dapr_component"
  for_each = var.dapr_components

  component_type         = each.value.component_type
  managed_environment    = { resource_id = azapi_resource.this_environment.id }
  name                   = each.key
  dapr_component_version = each.value.version
  ignore_errors          = each.value.ignore_errors
  init_timeout           = each.value.init_timeout
  metadata               = try(each.value.metadata, null)
  scopes                 = each.value.scopes
  secret                 = try(each.value.secret, null)
  secret_store_component = each.value.secret_store_component
  timeouts               = each.value.timeouts
}
