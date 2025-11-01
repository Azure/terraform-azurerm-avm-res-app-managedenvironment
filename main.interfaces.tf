# This file handles the AVM common interfaces (locks, role assignments, diagnostic settings)
# using the avm-utl-interfaces utility module and pure AzAPI resources

module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azurerm"
  version = "~> 0.4.0"

  diagnostic_settings              = var.diagnostic_settings
  lock                             = var.lock
  role_assignments                 = var.role_assignments
  role_assignment_definition_scope = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
}

# Management Lock using AzAPI
resource "azapi_resource" "lock" {
  count = module.avm_interfaces.lock_azapi != null ? 1 : 0

  type           = lookup(module.avm_interfaces.lock_azapi, "type", null)
  body           = lookup(module.avm_interfaces.lock_azapi, "body", null)
  locks          = [azapi_resource.this_environment.id]
  name           = lookup(module.avm_interfaces.lock_azapi, "name", null)
  parent_id      = azapi_resource.this_environment.id
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Role Assignments using AzAPI
resource "azapi_resource" "role_assignments" {
  for_each = module.avm_interfaces.role_assignments_azapi

  type      = each.value.type
  body      = each.value.body
  locks     = [azapi_resource.this_environment.id]
  name      = each.value.name
  parent_id = azapi_resource.this_environment.id

  lifecycle {
    ignore_changes = [
      name,
    ]
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Diagnostic Settings using AzAPI
resource "azapi_resource" "diagnostic_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  type      = each.value.type
  body      = each.value.body
  locks     = [azapi_resource.this_environment.id]
  name      = each.value.name
  parent_id = azapi_resource.this_environment.id

  # in order for 'location' to be accepted within the lifecycle block, schema validation must be turned off
  # ref: ignoring the location is required due to a spec bug upstream in the REST API
  # ref: https://github.com/Azure/terraform-provider-azapi/issues/655
  schema_validation_enabled = false

  lifecycle {
    ignore_changes = [
      location,
    ]
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Moved blocks for migration support from AzureRM to AzAPI
moved {
  from = azurerm_management_lock.this
  to   = azapi_resource.lock
}

moved {
  from = azurerm_role_assignment.this
  to   = azapi_resource.role_assignments
}

moved {
  from = azurerm_monitor_diagnostic_setting.this
  to   = azapi_resource.diagnostic_settings
}
