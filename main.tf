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
      daprAIInstrumentationKey = var.instrumentation_key
      peerAuthentication = {
        "mtls" : {
          "enabled" = var.peer_authentication_enabled
        }
      }
      infrastructureResourceGroup = var.infrastructure_resource_group_name
      vnetConfiguration = var.vnet_subnet_id != null ? {
        "internal"               = var.vnet_internal_only
        "infrastructureSubnetId" = var.vnet_subnet_id
      } : null
      workloadProfiles = var.workload_profiles_enabled ? setunion([
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
        }],
        var.workload_profiles
      ) : null
      zoneRedundant = var.zone_redundancy_enabled
    }
  })
  location                  = coalesce(var.location, data.azurerm_resource_group.parent.location)
  name                      = var.name
  parent_id                 = data.azurerm_resource_group.parent.id
  schema_validation_enabled = false
  tags                      = var.tags
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
