# Deprecated input shims for the previous azurerm-style API.
#
# New inputs take precedence. Deprecated inputs are nullable fallbacks that preserve
# compatibility while callers migrate.
#
# Non-ephemeral deprecated inputs warn via check blocks below. Ephemeral deprecated
# inputs cannot be referenced from check conditions, so those continue to fall back
# silently through locals.tf.

check "deprecated_custom_domain_dns_suffix" {
  assert {
    condition     = var.custom_domain_dns_suffix == null
    error_message = "Variable `custom_domain_dns_suffix` is deprecated. Use `custom_domain_configuration = { dns_suffix = \"...\" }` instead."
  }
}

check "deprecated_custom_domain_certificate_key_vault_url" {
  assert {
    condition     = var.custom_domain_certificate_key_vault_url == null
    error_message = "Variable `custom_domain_certificate_key_vault_url` is deprecated. Use `custom_domain_configuration.certificate_key_vault_properties.key_vault_url` instead."
  }
}

check "deprecated_custom_domain_certificate_key_vault_identity" {
  assert {
    condition     = var.custom_domain_certificate_key_vault_identity == null
    error_message = "Variable `custom_domain_certificate_key_vault_identity` is deprecated. Use `custom_domain_configuration.certificate_key_vault_properties.identity` instead."
  }
}

check "deprecated_custom_domain_certificate_value" {
  assert {
    condition     = var.custom_domain_certificate_value == null
    error_message = "Variable `custom_domain_certificate_value` is deprecated. Use `custom_domain_configuration.certificate_value` instead."
  }
}

check "deprecated_infrastructure_resource_group_name" {
  assert {
    condition     = var.infrastructure_resource_group_name == null
    error_message = "Variable `infrastructure_resource_group_name` is deprecated. Rename to `infrastructure_resource_group`."
  }
}

check "deprecated_infrastructure_subnet_id" {
  assert {
    condition     = var.infrastructure_subnet_id == null
    error_message = "Variable `infrastructure_subnet_id` is deprecated. Use `vnet_configuration = { infrastructure_subnet_id = \"...\" }` instead."
  }
}

check "deprecated_internal_load_balancer_enabled" {
  assert {
    condition     = var.internal_load_balancer_enabled == null
    error_message = "Variable `internal_load_balancer_enabled` is deprecated. Use `vnet_configuration = { internal = true }` instead."
  }
}

check "deprecated_log_analytics_workspace_customer_id" {
  assert {
    condition     = var.log_analytics_workspace_customer_id == null
    error_message = "Variable `log_analytics_workspace_customer_id` is deprecated. Use `app_logs_configuration.log_analytics_configuration.customer_id`, or set `log_analytics_workspace.resource_id` to auto-fetch."
  }
}

check "deprecated_log_analytics_workspace_destination" {
  assert {
    condition     = var.log_analytics_workspace_destination == null
    error_message = "Variable `log_analytics_workspace_destination` is deprecated. Use `app_logs_configuration.destination` instead."
  }
}

check "deprecated_peer_authentication_enabled" {
  assert {
    condition     = var.peer_authentication_enabled == null
    error_message = "Variable `peer_authentication_enabled` is deprecated. Use `peer_authentication = { mtls = { enabled = true } }` instead."
  }
}

check "deprecated_peer_traffic_encryption_enabled" {
  assert {
    condition     = var.peer_traffic_encryption_enabled == null
    error_message = "Variable `peer_traffic_encryption_enabled` is deprecated. Use `peer_traffic_configuration = { encryption = { enabled = true } }` instead."
  }
}

check "deprecated_public_network_access_enabled" {
  assert {
    condition     = var.public_network_access_enabled == null
    error_message = "Variable `public_network_access_enabled` is deprecated. Use `public_network_access` (\"Enabled\" or \"Disabled\") instead."
  }
}

check "deprecated_workload_profile" {
  assert {
    condition     = var.workload_profile == null
    error_message = "Variable `workload_profile` (set) is deprecated. Rename to `workload_profiles` (list)."
  }
}

check "deprecated_zone_redundancy_enabled" {
  assert {
    condition     = var.zone_redundancy_enabled == null
    error_message = "Variable `zone_redundancy_enabled` is deprecated. Rename to `zone_redundant`."
  }
}
