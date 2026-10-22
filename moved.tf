# These moved blocks allow existing Terraform state to be upgraded without destroying
# and recreating resources. Each block maps the old resource/module address to the new one.
#
# For-each modules: a single moved block covers all instances automatically
# (Terraform expands module.old[*] → module.new[*]).
#
# Submodule renames: singular names were changed to plural for consistency.

moved {
  from = module.certificate
  to   = module.certificates
}

moved {
  from = module.dapr_component
  to   = module.dapr_components
}

moved {
  from = module.managed_certificate
  to   = module.managed_certificates
}

moved {
  from = module.storage
  to   = module.storages
}

# The environment is the module's primary resource, so it is named `this`.
moved {
  from = azapi_resource.this_environment
  to   = azapi_resource.this
}

# The lock, role assignments and diagnostic settings moved from the AzureRM provider to AzAPI. They are
# adopted in place and updated with the same settings.
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
