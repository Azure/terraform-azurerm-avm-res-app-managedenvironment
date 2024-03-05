data "azurerm_resource_group" "parent" {
  name = var.resource_group_name
}

resource "azapi_resource" "this_environment" {
  type = "Microsoft.App/managedEnvironments@2023-05-01"
  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        "destination" = var.log_analytics_workspace_destination
        logAnalyticsConfiguration = var.log_analytics_workspace_destination == "log-analytics" ? {
          "customerId" = var.log_analytics_workspace_customer_id
          "sharedKey"  = var.log_analytics_workspace_primary_shared_key
        } : null
      }
      customDomainConfiguration = {
        "certificatePassword" = var.custom_domain_certificate_password
        "dnsSuffix"           = var.custom_domain_dns_suffix
      }
      daprAIInstrumentationKey = var.dapr_application_insights_connection_string
      peerAuthentication = {
        "mtls" : {
          "enabled" = var.peer_authentication_enabled
        }
      }
      infrastructureResourceGroup = var.infrastructure_resource_group_name
      vnetConfiguration = var.infrastructure_subnet_id != null ? {
        "internal"               = var.internal_load_balancer_enabled
        "infrastructureSubnetId" = var.infrastructure_subnet_id
      } : null
      workloadProfiles = var.workload_consumption_profile_enabled ? setunion([
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
        }],
        var.workload_profile
      ) : null
      zoneRedundant = var.zone_redundancy_enabled
    }
  })
  location  = coalesce(var.location, data.azurerm_resource_group.parent.location)
  name      = var.name
  parent_id = data.azurerm_resource_group.parent.id
  response_export_values = [
    "properties.customDomainConfiguration",
    "properties.daprAIInstrumentationKey",
    "properties.defaultDomain",
    "properties.infrastructureResourceGroup",
    "properties.peerAuthentication",
    "properties.staticIp",
    "properties.vnetConfiguration",
    "properties.workloadProfiles",
  ]
  schema_validation_enabled = true
  tags                      = var.tags
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

resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azapi_resource.this_environment.id
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
  for_each                       = var.diagnostic_settings
  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azapi_resource.this_environment.id
  storage_account_id             = each.value.storage_account_resource_id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  partner_solution_id            = each.value.marketplace_partner_resource_id
  log_analytics_workspace_id     = each.value.workspace_resource_id
  log_analytics_destination_type = each.value.log_analytics_destination_type

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
