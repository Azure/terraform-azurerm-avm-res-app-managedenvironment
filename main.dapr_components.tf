module "dapr_components" {
  source   = "./modules/dapr_components"
  for_each = var.dapr_components

  location                = var.location
  name                    = each.value.name
  parent_id               = azapi_resource.this.id
  component_type          = each.value.component_type
  dapr_components_version = each.value.dapr_components_version
  enable_telemetry        = var.enable_telemetry
  ignore_body_changes     = var.ignore_body_changes.app_managed_environments_dapr_components
  ignore_errors           = each.value.ignore_errors
  init_timeout            = each.value.init_timeout
  metadata                = each.value.metadata
  resource_types          = var.resource_types.app_managed_environments_dapr_components
  retry                   = var.retry
  scopes                  = each.value.scopes
  secret_store_component  = each.value.secret_store_component
  secrets                 = each.value.secrets
  secrets_version         = each.value.secrets_version
  timeouts                = var.timeouts
}
