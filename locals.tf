data "azapi_client_config" "current" {}

# Fetch the primary shared key from the Log Analytics Workspace (mirrors AzureRM provider behaviour).
# Only used when log_analytics_workspace.resource_id is set and var.shared_key is not provided.
ephemeral "azapi_resource_action" "shared_keys" {
  count = var.log_analytics_workspace != null ? 1 : 0

  action                 = "sharedKeys"
  method                 = "POST"
  resource_id            = var.log_analytics_workspace.resource_id
  type                   = "Microsoft.OperationalInsights/workspaces@2020-08-01"
  response_export_values = ["primarySharedKey"]
}

# Fetch the customer ID from the Log Analytics Workspace resource ID.
data "azapi_resource" "customer_id" {
  count = var.log_analytics_workspace != null ? 1 : 0

  resource_id            = var.log_analytics_workspace.resource_id
  type                   = "Microsoft.OperationalInsights/workspaces@2020-08-01"
  response_export_values = ["properties.customerId"]
}

# Effective locals that merge new and deprecated variable inputs.
# New variable always takes priority over its deprecated equivalent.
locals {
  # These locals are automatically treated as ephemeral since they depend on ephemeral input variables.
  effective_certificate_password = var.certificate_password != null ? var.certificate_password : var.custom_domain_certificate_password
  effective_certificate_value    = var.certificate_value != null ? var.certificate_value : try(local.effective_custom_domain_configuration.certificate_value, null)
  effective_custom_domain_configuration = var.custom_domain_configuration != null ? var.custom_domain_configuration : (
    var.custom_domain_dns_suffix != null ||
    var.custom_domain_certificate_value != null ||
    var.custom_domain_certificate_key_vault_url != null ||
    var.custom_domain_certificate_key_vault_identity != null ? {
      dns_suffix        = var.custom_domain_dns_suffix
      certificate_value = var.custom_domain_certificate_value
      certificate_key_vault_properties = (
        var.custom_domain_certificate_key_vault_url != null || var.custom_domain_certificate_key_vault_identity != null ? {
          key_vault_url = var.custom_domain_certificate_key_vault_url
          identity      = var.custom_domain_certificate_key_vault_identity
        } : null
      )
    } : null
  )
  effective_dapr_ai_connection_string     = var.dapr_ai_connection_string != null ? var.dapr_ai_connection_string : var.dapr_application_insights_connection_string
  effective_infrastructure_resource_group = var.infrastructure_resource_group != null ? var.infrastructure_resource_group : var.infrastructure_resource_group_name
  effective_peer_authentication = var.peer_authentication != null ? var.peer_authentication : (
    var.peer_authentication_enabled != null ? {
      mtls = { enabled = var.peer_authentication_enabled }
    } : null
  )
  effective_peer_traffic_configuration = var.peer_traffic_configuration != null ? var.peer_traffic_configuration : (
    var.peer_traffic_encryption_enabled != null ? {
      encryption = { enabled = var.peer_traffic_encryption_enabled }
    } : null
  )
  effective_vnet_configuration = var.vnet_configuration != null ? var.vnet_configuration : (
    var.internal_load_balancer_enabled != null || var.infrastructure_subnet_id != null ? {
      docker_bridge_cidr       = null
      infrastructure_subnet_id = var.infrastructure_subnet_id
      internal                 = var.internal_load_balancer_enabled
      platform_reserved_cidr   = null
      platform_reserved_dns_ip = null
    } : null
  )
  effective_zone_redundant = var.zone_redundant != null ? var.zone_redundant : var.zone_redundancy_enabled
}

locals {
  # Deprecated var.workload_profile (set) fallback — tolist() ordering is not guaranteed for sets.
  # var.workload_profiles (list) takes priority when both are set.
  _workload_profiles_input = var.workload_profiles != null ? var.workload_profiles : (
    var.workload_profile != null ? tolist(var.workload_profile) : null
  )
  # Resource ID maps for outputs
  certificate_resource_ids    = { for ck, cv in module.certificates : ck => { id = cv.resource_id } }
  dapr_component_resource_ids = { for dk, dv in module.dapr_components : dk => { id = dv.resource_id } }
  # Effective app logs configuration — merges var.app_logs_configuration with backward-compat
  # logic from log_analytics_workspace (resource ID-based) and deprecated flat variables.
  effective_app_logs_configuration = (
    var.app_logs_configuration != null ? var.app_logs_configuration : (
      var.log_analytics_workspace != null ? {
        destination = "log-analytics"
        log_analytics_configuration = {
          customer_id = try(data.azapi_resource.customer_id[0].output.properties.customerId, null)
        }
        } : (
        var.log_analytics_workspace_customer_id != null || var.log_analytics_workspace_destination != null ? {
          destination = coalesce(var.log_analytics_workspace_destination, "log-analytics")
          log_analytics_configuration = {
            customer_id = var.log_analytics_workspace_customer_id
          }
        } : null
      )
    )
  )
  # Accepts the deprecated public_network_access_enabled bool as a fallback.
  effective_public_network_access = (
    var.public_network_access != null ? var.public_network_access : (
      var.public_network_access_enabled != null ? (var.public_network_access_enabled ? "Enabled" : "Disabled") : null
    )
  )
  # Effective Log Analytics shared key — use explicit ephemeral var if provided, then deprecated
  # fallback, then auto-fetch from log_analytics_workspace resource ID.
  log_analytics_key = (
    var.shared_key != null ? var.shared_key : (
      var.log_analytics_workspace_primary_shared_key != null ? var.log_analytics_workspace_primary_shared_key : (
        length(ephemeral.azapi_resource_action.shared_keys) > 0 ?
        ephemeral.azapi_resource_action.shared_keys[0].output.primarySharedKey : null
      )
    )
  )
  managed_certificate_resource_ids = { for mck, mcv in module.managed_certificates : mck => { id = mcv.resource_id } }
  parent_id = var.parent_id != null ? var.parent_id : (
    var.resource_group_name != null ?
    "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}" :
    null
  )
  resource_body = {
    kind = var.kind
    properties = {
      appInsightsConfiguration = var.app_insights_configuration == null ? null : {}
      appLogsConfiguration = local.effective_app_logs_configuration == null ? null : {
        destination = local.effective_app_logs_configuration.destination
        logAnalyticsConfiguration = local.effective_app_logs_configuration.destination != "log-analytics" || try(local.effective_app_logs_configuration.log_analytics_configuration, null) == null ? null : {
          customerId         = try(local.effective_app_logs_configuration.log_analytics_configuration.customer_id, null)
          dynamicJsonColumns = try(local.effective_app_logs_configuration.log_analytics_configuration.dynamic_json_columns, null)
        }
      }
      availabilityZones = var.availability_zones == null ? null : [for item in var.availability_zones : item]
      customDomainConfiguration = local.effective_custom_domain_configuration == null ? null : {
        certificateKeyVaultProperties = try(local.effective_custom_domain_configuration.certificate_key_vault_properties, null) == null ? null : {
          identity    = local.effective_custom_domain_configuration.certificate_key_vault_properties.identity
          keyVaultUrl = local.effective_custom_domain_configuration.certificate_key_vault_properties.key_vault_url
        }
        dnsSuffix = try(local.effective_custom_domain_configuration.dns_suffix, null)
      }
      daprConfiguration = var.dapr_configuration == null ? null : {}
      diskEncryptionConfiguration = var.disk_encryption_configuration == null ? null : {
        keyVaultConfiguration = var.disk_encryption_configuration.key_vault_configuration == null ? null : {
          auth = var.disk_encryption_configuration.key_vault_configuration.auth == null ? null : {
            identity = var.disk_encryption_configuration.key_vault_configuration.auth.identity
          }
          keyUrl = var.disk_encryption_configuration.key_vault_configuration.key_url
        }
      }
      infrastructureResourceGroup = local.effective_infrastructure_resource_group
      ingressConfiguration = var.ingress_configuration == null ? null : {
        headerCountLimit              = var.ingress_configuration.header_count_limit
        requestIdleTimeout            = var.ingress_configuration.request_idle_timeout
        terminationGracePeriodSeconds = var.ingress_configuration.termination_grace_period_seconds
        workloadProfileName           = var.ingress_configuration.workload_profile_name
      }
      kedaConfiguration = var.keda_configuration == null ? null : {}
      openTelemetryConfiguration = var.open_telemetry_configuration == null ? null : {
        destinationsConfiguration = var.open_telemetry_configuration.destinations_configuration == null ? null : {
          dataDogConfiguration = var.open_telemetry_configuration.destinations_configuration.data_dog_configuration == null ? null : {
            site = var.open_telemetry_configuration.destinations_configuration.data_dog_configuration.site
          }
          otlpConfigurations = var.open_telemetry_configuration.destinations_configuration.otlp_configurations == null ? null : [for item in var.open_telemetry_configuration.destinations_configuration.otlp_configurations : item == null ? null : {
            endpoint = item.endpoint
            headers = item.headers == null ? null : [for hdr in item.headers : hdr == null ? null : {
              key   = hdr.key
              value = hdr.value
            }]
            insecure = item.insecure
            name     = item.name
          }]
        }
        logsConfiguration = var.open_telemetry_configuration.logs_configuration == null ? null : {
          destinations = var.open_telemetry_configuration.logs_configuration.destinations == null ? null : [for item in var.open_telemetry_configuration.logs_configuration.destinations : item]
        }
        metricsConfiguration = var.open_telemetry_configuration.metrics_configuration == null ? null : {
          destinations = var.open_telemetry_configuration.metrics_configuration.destinations == null ? null : [for item in var.open_telemetry_configuration.metrics_configuration.destinations : item]
          includeKeda  = var.open_telemetry_configuration.metrics_configuration.include_keda
        }
        tracesConfiguration = var.open_telemetry_configuration.traces_configuration == null ? null : {
          destinations = var.open_telemetry_configuration.traces_configuration.destinations == null ? null : [for item in var.open_telemetry_configuration.traces_configuration.destinations : item]
          includeDapr  = var.open_telemetry_configuration.traces_configuration.include_dapr
        }
      }
      peerAuthentication = local.effective_peer_authentication == null ? null : {
        mtls = try(local.effective_peer_authentication.mtls, null) == null ? null : {
          enabled = local.effective_peer_authentication.mtls.enabled
        }
      }
      peerTrafficConfiguration = local.effective_peer_traffic_configuration == null ? null : {
        encryption = try(local.effective_peer_traffic_configuration.encryption, null) == null ? null : {
          enabled = local.effective_peer_traffic_configuration.encryption.enabled
        }
      }
      publicNetworkAccess = local.effective_public_network_access
      vnetConfiguration = local.effective_vnet_configuration == null ? null : {
        dockerBridgeCidr       = local.effective_vnet_configuration.docker_bridge_cidr
        infrastructureSubnetId = local.effective_vnet_configuration.infrastructure_subnet_id
        internal               = local.effective_vnet_configuration.internal
        platformReservedCidr   = local.effective_vnet_configuration.platform_reserved_cidr
        platformReservedDnsIP  = local.effective_vnet_configuration.platform_reserved_dns_ip
      }
      workloadProfiles = local.workload_profiles
      zoneRedundant    = local.effective_zone_redundant
    }
  }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  storage_resource_ids               = { for sk, sv in module.storages : sk => { id = sv.resource_id } }
  # Workload profiles idempotency fix: when dedicated profiles are specified, always add a Consumption
  # profile to avoid drift on subsequent runs (Azure creates one implicitly).
  workload_profiles = (
    local._workload_profiles_input != null && length(local._workload_profiles_input) > 0 ? concat(
      [
        for wp in local._workload_profiles_input : {
          name                = wp.name
          workloadProfileType = wp.workload_profile_type
          minimumCount        = wp.minimum_count
          maximumCount        = wp.maximum_count
        }
        if wp.workload_profile_type != "Consumption"
      ],
      [
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
          minimumCount        = null
          maximumCount        = null
        }
      ]
    ) : null
  )
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
