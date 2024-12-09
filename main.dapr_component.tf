module "dapr_component" {
  source   = "./modules/dapr_component"
  for_each = var.dapr_components

  name                = each.key
  managed_environment = { resource_id = azapi_resource.this_environment.id }

  component_type         = each.value.component_type
  ignore_errors          = each.value.ignore_errors
  init_timeout           = each.value.init_timeout
  secret_store_component = each.value.secret_store_component
  scopes                 = each.value.scopes
  dapr_component_version = each.value.version

  metadata = try(each.value.metadata, null)
  secret   = try(each.value.secret, null)

  timeouts = each.value.timeouts
}
