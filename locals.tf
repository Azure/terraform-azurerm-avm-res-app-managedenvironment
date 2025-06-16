data "azapi_client_config" "current" {}

locals {
  container_app_environment_properties = merge({
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
    workloadProfiles = local.workload_profiles
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
  dapr_component_resource_ids = {
    for dk, dv in module.dapr_component :
    dk => {
      id = dv.resource_id
    }
  }
  resource_group_id                  = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  storage_resource_ids = {
    for sk, sv in module.storage :
    sk => {
      id = sv.resource_id
    }
  }
  # workload profiles can be null, in this case a Consumption Only plan is created.
  workload_profiles = length(var.workload_profile) > 0 ? toset(concat(
    [
      for wp in var.workload_profile : {
        name                = wp.name
        workloadProfileType = wp.workload_profile_type
        minimumCount        = wp.minimum_count
        maximumCount        = wp.maximum_count
      }
      if wp.workload_profile_type != "Consumption"
    ],
    # if you specify a dedicated workload profile, then a consumption profile is also created automatically.
    # we add this block to avoid idempotency issues on subsequent runs.
    # the consumption profile is a special case that does not need a minimum or maximum count
    # there can be at most one consumption profile.
    [
      {
        name                = "Consumption"
        workloadProfileType = "Consumption"
        minimumCount        = null
        maximumCount        = null
      }
    ]
  )) : null
}

locals {
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
}
