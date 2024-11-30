output "custom_domain_verification_id" {
  description = "The custom domain verification ID of the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.properties.customDomainConfiguration.customDomainVerificationId, null)
}

output "dapr_component_metadata_secrets" {
  description = "The metadata secrets output of the Dapr components."
  sensitive   = true
  value       = local.dapr_component_metadata_secrets_output
}

output "dapr_component_secrets" {
  description = "The secrets output of the Dapr components."
  sensitive   = true
  value       = local.dapr_component_secrets_output
}

output "dapr_components" {
  description = "A map of dapr components connected to this environment. The map key is the supplied input to var.storages. The map value is the azurerm-formatted version of the entire dapr_components resource."
  value       = local.dapr_component_outputs
}

output "default_domain" {
  description = "The default domain of the Container Apps Managed Environment."
  value       = azapi_resource.this_environment.output.properties.defaultDomain
}

output "docker_bridge_cidr" {
  description = "The Docker bridge CIDR of the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.properties.vnetConfiguration.dockerBridgeCidr, null)
}

output "id" {
  description = "The ID of the container app management environment resource."
  value       = azapi_resource.this_environment.id
}

output "infrastructure_resource_group" {
  description = "The infrastructure resource group of the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.properties.infrastructureResourceGroup, null)
}

output "mtls_enabled" {
  description = "Indicates if mTLS is enabled for the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.properties.peerAuthentication.mtls.enabled, false)
}

output "name" {
  description = "The name of the resource"
  value       = azapi_resource.this_environment.name
}

output "platform_reserved_cidr" {
  description = "The platform reserved CIDR of the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.properties.vnetConfiguration.platformReservedCidr, null)
}

output "platform_reserved_dns_ip_address" {
  description = "The platform reserved DNS IP address of the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.properties.vnetConfiguration.platformReservedDnsIP, null)
}

output "resource_id" {
  description = "The ID of the container app management environment resource."
  value       = azapi_resource.this_environment.id
}

output "static_ip_address" {
  description = "The static IP address of the Container Apps Managed Environment."
  value       = azapi_resource.this_environment.output.properties.staticIp
}

output "storage_access_keys" {
  description = "The access key outputs of the storage resources."
  sensitive   = true
  value       = local.storage_access_key_outputs
}

output "storages" {
  description = "A map of storage shares connected to this environment. The map key is the supplied input to var.storages. The map value is the azurerm-formatted version of the entire storage shares resource."
  value       = local.storages_outputs
}
