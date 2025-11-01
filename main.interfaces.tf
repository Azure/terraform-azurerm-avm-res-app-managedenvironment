# This file handles the AVM common interfaces (locks, role assignments, diagnostic settings)
# using the avm-utl-interfaces utility module and pure AzAPI resources

module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "~> 0.4.0"

  diagnostic_settings              = var.diagnostic_settings
  lock                             = var.lock
  role_assignment_definition_scope = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  role_assignments                 = var.role_assignments
}

# Management Lock using AzAPI
resource "azapi_resource" "lock" {
  count = module.avm_interfaces.lock_azapi != null ? 1 : 0

  name           = lookup(module.avm_interfaces.lock_azapi, "name", null)
  parent_id      = azapi_resource.this_environment.id
  type           = lookup(module.avm_interfaces.lock_azapi, "type", null)
  body           = lookup(module.avm_interfaces.lock_azapi, "body", null)
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  locks          = [azapi_resource.this_environment.id]
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Role Assignments using AzAPI
resource "azapi_resource" "role_assignments" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name           = each.value.name
  parent_id      = azapi_resource.this_environment.id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  locks          = [azapi_resource.this_environment.id]
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    ignore_changes = [
      name,
    ]
  }
}

# Diagnostic Settings using AzAPI
resource "azapi_resource" "diagnostic_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi

  name           = each.value.name
  parent_id      = azapi_resource.this_environment.id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  locks          = [azapi_resource.this_environment.id]
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # in order for 'location' to be accepted within the lifecycle block, schema validation must be turned off
  # ref: ignoring the location is required due to a spec bug upstream in the REST API
  # ref: https://github.com/Azure/terraform-provider-azapi/issues/655
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    ignore_changes = [
      location,
    ]
  }
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
