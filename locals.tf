data "azapi_client_config" "current" {}

# this will attempt to get the primary shared key from the Log Analytics Workspace, mirroring the behaviour of AzureRM provider.
# optionally, log_analytics_workspace_primary_shared_key can be set to a value, in which case this will not be used.
ephemeral "azapi_resource_action" "shared_keys" {
  count = var.log_analytics_workspace != null ? 1 : 0

  action                 = "sharedKeys"
  method                 = "POST"
  resource_id            = var.log_analytics_workspace.resource_id
  type                   = "Microsoft.OperationalInsights/workspaces@2020-08-01"
  response_export_values = ["primarySharedKey"]
}

# if the resource ID is specified, fetch the customer ID.
data "azapi_resource" "customer_id" {
  count = var.log_analytics_workspace != null ? 1 : 0

  resource_id            = var.log_analytics_workspace.resource_id
  type                   = "Microsoft.OperationalInsights/workspaces@2020-08-01"
  response_export_values = ["properties.customerId"]
}

locals {
  certificate_resource_ids = {
    for ck, cv in module.certificate :
    ck => {
      id = cv.resource_id
    }
  }
  container_app_environment_properties = merge({
    appLogsConfiguration = {
      "destination" = var.log_analytics_workspace_destination == "none" ? "" : var.log_analytics_workspace_destination
      logAnalyticsConfiguration = var.log_analytics_workspace_destination == "log-analytics" ? {
        "customerId" = coalesce(var.log_analytics_workspace_customer_id, try(data.azapi_resource.customer_id[0].output.properties.customerId, null))
      } : null
    }
    customDomainConfiguration = merge(
      {
        "certificatePassword" = var.custom_domain_certificate_password
        "dnsSuffix"           = var.custom_domain_dns_suffix
      },
      var.custom_domain_certificate_key_vault_url != null ? {
        certificateKeyVaultProperties = {
          identity    = var.custom_domain_certificate_key_vault_identity
          keyVaultUrl = var.custom_domain_certificate_key_vault_url
        }
      } : {}
    )
    daprAIConnectionString = var.dapr_application_insights_connection_string
    peerAuthentication = {
      "mtls" : {
        "enabled" = var.peer_authentication_enabled
      }
    }
    peerTrafficConfiguration = {
      "encryption" : {
        "enabled" = var.peer_traffic_encryption_enabled
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
  # container_app_environment_sensitive_properties = merge(
  #   var.log_analytics_workspace_destination == "log-analytics" ? {
  #     appLogsConfiguration = {
  #       logAnalyticsConfiguration = {
  #         sharedKey = local.log_analytics_key
  #       }
  #     }
  #   } : {}
  # )
  container_app_environment_sensitive_properties = merge(
    {
      appLogsConfiguration = {
        logAnalyticsConfiguration = var.log_analytics_workspace_destination == "log-analytics" ? {
          sharedKey = local.log_analytics_key
        } : null
      }
    },
    var.custom_domain_certificate_value != null ? {
      customDomainConfiguration = {
        certificateValue = var.custom_domain_certificate_value
      }
    } : {}
  )
  dapr_component_resource_ids = {
    for dk, dv in module.dapr_component :
    dk => {
      id = dv.resource_id
    }
  }
  # get the key via the workspace resource ID if this is set.
  log_analytics_key = (var.log_analytics_workspace_destination != "log-analytics" ? null :
    length(ephemeral.azapi_resource_action.shared_keys) > 0 ?
    ephemeral.azapi_resource_action.shared_keys[0].output.primarySharedKey : var.log_analytics_workspace_primary_shared_key
  )
  managed_certificate_resource_ids = {
    for mck, mcv in module.managed_certificate :
    mck => {
      id = mcv.resource_id
    }
  }
  parent_id = var.parent_id != null ? var.parent_id : (
    var.resource_group_name != null ?
    "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}" :
    null
  )
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
