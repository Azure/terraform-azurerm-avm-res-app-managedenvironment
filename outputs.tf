output "certificate_resource_ids" {
  description = "A map of certificates connected to this environment. The map key is the supplied input to var.certificates. The map value is the azurerm-formatted version of the entire certificate resource."
  value       = local.certificate_resource_ids
}

output "custom_domain_verification_id" {
  description = "The custom domain verification ID of the Container Apps Managed Environment."
  sensitive   = true
  value       = try(azapi_resource.this_environment.output.properties.customDomainConfiguration.customDomainVerificationId, null)
}

output "dapr_component_resource_ids" {
  description = "A map of dapr components connected to this environment. The map key is the supplied input to var.dapr_components. The map value is the azurerm-formatted version of the entire dapr_components resource."
  value       = local.dapr_component_resource_ids
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

output "managed_certificate_resource_ids" {
  description = "A map of managed certificates connected to this environment. The map key is the supplied input to var.managed_certificates. The map value is the azurerm-formatted version of the entire managed certificate resource."
  value       = local.managed_certificate_resource_ids
}

output "managed_identities" {
  description = "The managed identities assigned to the Container Apps Managed Environment."
  value       = try(azapi_resource.this_environment.output.identity, {})
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

output "storage_resource_ids" {
  description = "A map of storage shares connected to this environment. The map key is the supplied input to var.storages. The map value is the azurerm-formatted version of the entire storage shares resource."
  value       = local.storage_resource_ids
}
