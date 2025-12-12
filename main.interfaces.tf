# This file handles the AVM common interfaces (locks, role assignments, diagnostic settings)
# using the avm-utl-interfaces utility module v1.0 prep branch
#
# NOTE: Using fix/role_assignment branch which includes drift fixes for both
# diagnostic_settings and role_assignments using the 3-step reconciliation pattern.
#
# Upstream PRs:
# - https://github.com/Azure/terraform-azure-avm-utl-interfaces/tree/feat/prepv1 (diagnostic_settings fix)
# - https://github.com/Azure/terraform-azure-avm-utl-interfaces/pull/31 (role_assignments fix)
#
# Context: Temporary workaround until azapi provider is updated to ignore null properties
# See: https://github.com/Azure/terraform-provider-azapi/issues/995
# The 3-step pattern (create with ignore_changes + read + update) is necessary but fragile.

module "avm_interfaces" {
  source = "git::https://github.com/kewalaka/terraform-azure-avm-utl-interfaces-1.git?ref=fix/role_assignment"

  parent_id           = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  this_resource_id    = azapi_resource.this_environment.id
  diagnostic_settings = var.diagnostic_settings
  enable_telemetry    = var.enable_telemetry
  lock                = var.lock
  role_assignments    = var.role_assignments
}

# Note: The feat/prepv1 branch creates all resources internally
# No need for manual azapi_resource blocks for lock, role_assignments, or diagnostic_settings
