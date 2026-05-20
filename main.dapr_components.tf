module "dapr_components" {
  source   = "./modules/dapr_components"
  for_each = var.dapr_components

  name                    = each.value.name
  parent_id               = azapi_resource.this_environment.id
  component_type          = each.value.component_type
  dapr_components_version = each.value.dapr_components_version
  enable_telemetry        = var.enable_telemetry
  ignore_errors           = each.value.ignore_errors
  init_timeout            = each.value.init_timeout
  metadata                = each.value.metadata
  scopes                  = each.value.scopes
  secret_store_component  = each.value.secret_store_component
  secrets                 = each.value.secrets
  secrets_version         = each.value.secrets_version
}
