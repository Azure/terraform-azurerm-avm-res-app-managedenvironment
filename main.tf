data "azurerm_client_config" "current" {}

resource "azapi_resource" "this_environment" {
  type = "Microsoft.App/managedEnvironments@2024-03-01"
  body = {
    properties = merge({
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
      vnetConfiguration = var.infrastructure_subnet_id != null ? {
        "internal"               = var.internal_load_balancer_enabled
        "infrastructureSubnetId" = var.infrastructure_subnet_id
      } : null
      workloadProfiles = length(local.workload_profiles) > 0 ? local.workload_profiles : null
      zoneRedundant    = var.zone_redundancy_enabled
      },
      # Only include the infrastructureResourceGroup property if it is set
      #
      # Background: When using workload profiles, Azure will create a managed resource group for the container app environment.
      # If you want to specify a name for this resource group, you use the infrastructure_resource_group_name variable.
      # If you do not specify a name, Azure will create a name like "ME_myEnvironmentName_myResourceGroup_myRegion".
      #
      # The problem: if you do not specify a name, the next time a deployment runs, Terraform will see that the infrastructure_resource_group_name
      # has changed from null to the managed name, and will try to update the resource. This fails the idempotency check "no changes to plan after apply".
      var.infrastructure_resource_group_name != null ? {
        infrastructureResourceGroup = var.infrastructure_resource_group_name
      } : {}
    )
  }
  location  = var.location
  name      = var.name
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  response_export_values = [
    "properties.customDomainConfiguration",
    "properties.daprAIInstrumentationKey",
    "properties.defaultDomain",
    "properties.infrastructureResourceGroup",
    "properties.dockerBridgeCidr",
    "properties.platformReservedCidr",
    "properties.platformReservedDnsIP",
    "properties.staticIp",
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
