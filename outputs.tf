# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs

output "resource" {
  description = "The Container Apps Managed Environment resource."
  value = {
    id                  = azapi_resource.this_environment.id
    name                = azapi_resource.this_environment.name
    resource_group_name = data.azurerm_resource_group.parent.name
    location            = jsondecode(data.azapi_resource.this_environment.output).location

    # outputs provided by the AzureRM provider
    dapr_application_insights_connection_string = try(jsondecode(data.azapi_resource.this_environment.output).properties.daprAIInstrumentationKey, null)
    infrastructure_subnet_id                    = try(jsondecode(data.azapi_resource.this_environment.output).properties.vnetConfiguration.infrastructureSubnetId, null)
    internal_load_balancer_enabled              = try(jsondecode(data.azapi_resource.this_environment.output).properties.vnetConfiguration.internal, null)
    zone_redundancy_enabled                     = try(jsondecode(data.azapi_resource.this_environment.output).properties.zoneRedundant, null)
    log_analytics_workspace_id                  = try(jsondecode(data.azapi_resource.this_environment.output).properties.appLogsConfiguration.logAnalyticsConfiguration.customerId, null)
    tags                                        = try(azapi_resource.this_environment.tags, null)
    workload_profiles                           = local.workload_profile_outputs

    default_domain                   = jsondecode(data.azapi_resource.this_environment.output).properties.defaultDomain
    docker_bridge_cidr               = try(jsondecode(data.azapi_resource.this_environment.output).properties.vnetConfiguration.dockerBridgeCidr, null)
    platform_reserved_cidr           = try(jsondecode(data.azapi_resource.this_environment.output).properties.vnetConfiguration.platformReservedCidr, null)
    platform_reserved_dns_ip_address = try(jsondecode(data.azapi_resource.this_environment.output).properties.vnetConfiguration.platformReservedDnsIP, null)
    static_ip_address                = jsondecode(data.azapi_resource.this_environment.output).properties.staticIp

    # additional outputs not yet supported by the AzureRM provider
    custom_domain_verification_id = try(jsondecode(data.azapi_resource.this_environment.output).properties.customDomainConfiguration.customDomainVerificationId, null)
    mtls_enabled                  = try(jsondecode(data.azapi_resource.this_environment.output).properties.peerAuthentication.mtls.enabled, false)
    infrastructure_resource_group = try(jsondecode(data.azapi_resource.this_environment.output).properties.infrastructureResourceGroup, null)

  }
}

output "id" {
  description = "The ID of the resource."
  value       = azapi_resource.this_environment.id
}

output "name" {
  description = "The name of the resource"
  value       = azapi_resource.this_environment.name
}
