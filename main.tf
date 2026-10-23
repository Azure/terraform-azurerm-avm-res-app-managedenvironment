resource "azapi_resource" "this" {
  location             = var.location
  name                 = var.name
  parent_id            = local.parent_id
  type                 = var.resource_types.app_managed_environments
  body                 = local.resource_body
  ignore_body_changes  = length(var.ignore_body_changes.app_managed_environments) > 0 ? var.ignore_body_changes.app_managed_environments : null
  ignore_null_property = true
  replace_triggers_refs = [
    "kind",
    "properties.infrastructureResourceGroup",
    "properties.vnetConfiguration.infrastructureSubnetId",
    "properties.vnetConfiguration.internal",
    "properties.zoneRedundant",
    "properties.workloadProfiles[*].workloadProfileType",
  ]
  response_export_values = [
    "identity",
    "properties.customDomainConfiguration",
    "properties.daprAIInstrumentationKey",
    "properties.daprConfiguration.version",
    "properties.defaultDomain",
    "properties.eventStreamEndpoint",
    "properties.infrastructureResourceGroup",
    "properties.kedaConfiguration.version",
    "properties.privateEndpointConnections",
    "properties.privateLinkDefaultDomain",
    "properties.staticIp",
    "properties.vnetConfiguration.dockerBridgeCidr",
    "properties.vnetConfiguration.platformReservedCidr",
    "properties.vnetConfiguration.platformReservedDnsIP",
  ]
  retry                     = var.retry
  schema_validation_enabled = true
  sensitive_body = {
    properties = {
      appInsightsConfiguration = var.app_insights_configuration == null ? null : {
        connectionString = var.connection_string
      }
      appLogsConfiguration = local.effective_app_logs_configuration == null || local.effective_app_logs_configuration.destination != "log-analytics" || local.log_analytics_key == null ? null : {
        logAnalyticsConfiguration = {
          sharedKey = local.log_analytics_key
        }
      }
      customDomainConfiguration = local.effective_custom_domain_configuration == null ? null : {
        certificatePassword = local.effective_certificate_password
        certificateValue    = local.effective_certificate_value
      }
      daprAIConnectionString   = local.effective_dapr_ai_connection_string
      daprAIInstrumentationKey = var.dapr_ai_instrumentation_key
      openTelemetryConfiguration = var.open_telemetry_configuration == null ? null : {
        destinationsConfiguration = {
          dataDogConfiguration = {
            key = var.key
          }
        }
      }
    }
  }
  sensitive_body_version = merge(
    {
      "properties.appInsightsConfiguration.connectionString"                                     = var.connection_string_version
      "properties.customDomainConfiguration.certificatePassword"                                 = var.certificate_password_version
      "properties.customDomainConfiguration.certificateValue"                                    = var.certificate_value_version
      "properties.daprAIConnectionString"                                                        = var.dapr_ai_connection_string_version
      "properties.daprAIInstrumentationKey"                                                      = var.dapr_ai_instrumentation_key_version
      "properties.openTelemetryConfiguration.destinationsConfiguration.dataDogConfiguration.key" = var.key_version
    },
    local.effective_app_logs_configuration != null && local.effective_app_logs_configuration.destination == "log-analytics" ? {
      "properties.appLogsConfiguration.logAnalyticsConfiguration.sharedKey" = coalesce(var.shared_key_version, 1)
    } : {}
  )
  tags = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition = local.effective_app_logs_configuration == null || local.effective_app_logs_configuration.destination != "log-analytics" || (
        try(local.effective_app_logs_configuration.log_analytics_configuration.customer_id, null) != null &&
        local.log_analytics_key != null
      )
      error_message = "When app_logs_configuration.destination is \"log-analytics\", both a customer_id and shared_key are required. Set log_analytics_workspace.resource_id or provide app_logs_configuration.log_analytics_configuration.customer_id together with shared_key."
    }
    precondition {
      condition = !(
        local.effective_vnet_configuration != null &&
        local.effective_vnet_configuration.internal == true &&
        local.effective_public_network_access == "Enabled"
      )
      error_message = "public_network_access cannot be \"Enabled\" when vnet_configuration.internal is true. Set public_network_access to \"Disabled\" or disable the internal load balancer."
    }
  }
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.this.id
  type      = var.resource_types.authorization_locks
  body = {
    properties = {
      level = var.lock.kind
      notes = coalesce(var.lock.notes, local.lock_notes[var.lock.kind])
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  # Create the lock last and remove it first. A ReadOnly lock blocks changes to the child resources.
  depends_on = [time_sleep.lock_removal]
}

# Azure keeps enforcing a deleted lock for a few seconds, and the AzAPI provider does not wait for it to
# be gone as the AzureRM provider did. This pause is destroyed after the lock and before the environment
# and the resources under it, so they are not deleted while the lock still applies.
resource "time_sleep" "lock_removal" {
  count = var.lock != null ? 1 : 0

  destroy_duration = "30s"
  # Replacing the environment replaces its lock, so the pause is replaced with them.
  triggers = {
    environment_id = azapi_resource.this.id
  }

  depends_on = [
    azapi_resource.diagnostic_settings,
    azapi_resource.role_assignments,
    module.certificates,
    module.dapr_components,
    module.dapr_subscriptions,
    module.dot_net_components,
    module.http_route_configs,
    module.java_components,
    module.maintenance_configurations,
    module.managed_certificates,
    module.storages,
  ]
}

# Role definitions are resolved here, case-insensitively as the AzureRM provider did, rather than by the
# interfaces module, whose lookup is case-sensitive. They are listed in the resource group rather than on
# the environment, so the lookup does not wait for pending changes to the environment and a role name
# that does not exist fails during plan.
data "azapi_resource_list" "role_definitions" {
  count = length(var.role_assignments) > 0 ? 1 : 0

  parent_id = local.parent_id
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  response_export_values = {
    results = "value[].{id: id, role_name: properties.roleName}"
  }
}

module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.9.0"

  location                                  = var.location
  enable_telemetry                          = var.enable_telemetry
  role_assignment_definition_lookup_enabled = false
  role_assignments                          = local.role_assignments
}

resource "azapi_resource" "role_assignments" {
  for_each = var.role_assignments

  name                 = module.avm_interfaces.role_assignments_azapi[each.key].name
  parent_id            = azapi_resource.this.id
  type                 = var.resource_types.authorization_role_assignments
  body                 = module.avm_interfaces.role_assignments_azapi[each.key].body
  ignore_body_changes  = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  ignore_casing        = true
  ignore_null_property = true
  # The AzureRM provider replaced a role assignment whenever one of its inputs changed. The inputs are
  # compared, rather than body paths or the resolved role definition ID, because Azure normalises role
  # definition IDs. While the prior value is null, as it is straight after upgrading from AzureRM,
  # nothing is replaced.
  replace_triggers_external_values = {
    condition                              = each.value.condition
    condition_version                      = each.value.condition_version
    delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
    description                            = each.value.description
    name                                   = each.value.name
    principal_id                           = lower(each.value.principal_id)
    principal_type                         = local.role_assignments[each.key].principal_type
    role_definition_id_or_name             = lower(each.value.role_definition_id_or_name)
  }
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    # Upgraded assignments keep the GUID the AzureRM provider generated, while the interfaces module
    # generates a new one. Replacing them would fail under a CanNotDelete lock. A change to an explicit
    # name still replaces the assignment through replace_triggers_external_values.
    ignore_changes = [name]

    precondition {
      condition     = strcontains(lower(local.role_assignments[each.key].role_definition_id_or_name), local.role_definition_resource_substring)
      error_message = "The role definition `${each.value.role_definition_id_or_name}` was not found in the resource group. Use the name of a role definition that can be assigned there, or the role definition's resource ID."
    }
  }
}

resource "azapi_resource" "diagnostic_settings" {
  for_each = var.diagnostic_settings

  name      = each.value.name != null ? each.value.name : "diag-${var.name}"
  parent_id = azapi_resource.this.id
  type      = var.resource_types.insights_diagnostic_settings
  body = {
    properties = merge(
      {
        eventHubAuthorizationRuleId = each.value.event_hub_authorization_rule_resource_id
        eventHubName                = each.value.event_hub_name
        # This module has always sent "Dedicated" as null, which leaves the choice to Azure.
        logAnalyticsDestinationType = each.value.log_analytics_destination_type == "Dedicated" ? null : each.value.log_analytics_destination_type
        logs = tolist(concat(
          [for category in each.value.log_categories : { category = category, categoryGroup = null, enabled = true }],
          [for group in each.value.log_groups : { category = null, categoryGroup = group, enabled = true }],
        ))
        marketplacePartnerId = each.value.marketplace_partner_resource_id
        storageAccountId     = each.value.storage_account_resource_id
        workspaceId          = each.value.workspace_resource_id
      },
      # Azure lists every metric category, disabled, when none is sent, so an empty list is not sent.
      length(each.value.metric_categories) > 0 ? {
        metrics = [for category in each.value.metric_categories : { category = category, enabled = true }]
      } : {},
    )
  }
  ignore_body_changes = length(var.ignore_body_changes.insights_diagnostic_settings) > 0 ? var.ignore_body_changes.insights_diagnostic_settings : null
  ignore_casing       = true
  # Azure returns every log category group of the environment, disabling those that were not sent. List
  # items are matched by category and items that are not configured are ignored, so they are not
  # reported as changes.
  ignore_other_items_in_list = ["properties.logs", "properties.metrics"]
  list_unique_id_property = {
    "properties.logs"    = "category, categoryGroup"
    "properties.metrics" = "category"
  }
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
