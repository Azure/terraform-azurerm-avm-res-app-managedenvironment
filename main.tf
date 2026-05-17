resource "azapi_resource" "this_environment" {
  location             = var.location
  name                 = var.name
  parent_id            = local.parent_id
  type                 = "Microsoft.App/managedEnvironments@2025-10-02-preview"
  body                 = local.resource_body
  create_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_null_property = true
  read_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
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
    local.effective_app_logs_configuration != null && local.effective_app_logs_configuration.destination == "log-analytics" && var.shared_key_version != null ? {
      "properties.appLogsConfiguration.logAnalyticsConfiguration.sharedKey" = var.shared_key_version
    } : {}
  )
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

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

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.this_environment.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.this_environment.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azapi_resource.this_environment.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}
