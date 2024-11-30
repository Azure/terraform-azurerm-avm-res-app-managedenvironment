output "id" {
  description = "The resource ID of the Container Apps Managed Environment."
  value       = module.managedenvironment.id
}

output "resource_id" {
  description = "The resource ID of the Container Apps Managed Environment."
  value       = module.managedenvironment.resource_id
}

output "name" {
  description = "The name of the Container Apps Managed Environment."
  value       = module.managedenvironment.name
}

output "default_domain" {
  description = "The default domain of the Container Apps Managed Environment."
  value       = module.managedenvironment.default_domain
}

output "docker_bridge_cidr" {
  description = "The Docker bridge CIDR of the Container Apps Managed Environment."
  value       = module.managedenvironment.docker_bridge_cidr
}

output "platform_reserved_cidr" {
  description = "The platform reserved CIDR of the Container Apps Managed Environment."
  value       = module.managedenvironment.platform_reserved_cidr
}

output "platform_reserved_dns_ip_address" {
  description = "The platform reserved DNS IP address of the Container Apps Managed Environment."
  value       = module.managedenvironment.platform_reserved_dns_ip_address
}

output "static_ip_address" {
  description = "The static IP address of the Container Apps Managed Environment."
  value       = module.managedenvironment.static_ip_address
}

output "infrastructure_resource_group" {
  description = "The infrastructure resource group of the Container Apps Managed Environment."
  value       = module.managedenvironment.infrastructure_resource_group
}

output "mtls_enabled" {
  description = "Indicates if mTLS is enabled for the Container Apps Managed Environment."
  value       = module.managedenvironment.mtls_enabled
}

output "dapr_components" {
  description = "A map of dapr components connected to this environment. The map key is the supplied input to var.storages. The map value is the azurerm-formatted version of the entire dapr_components resource."
  value       = module.managedenvironment.dapr_components
}

output "dapr_component_metadata_secrets" {
  description = "The metadata secrets output of the Dapr components."
  value       = module.managedenvironment.dapr_component_metadata_secrets
  sensitive   = true
}

output "dapr_component_secrets" {
  description = "The secrets output of the Dapr components."
  value       = module.managedenvironment.dapr_component_secrets
  sensitive   = true
}

output "storages" {
  description = "The storage of the Container Apps Managed Environment."
  value       = module.managedenvironment.storages
}

output "storages_access_keys" {
  description = "The storage access keys for storage resources attached to the Container Apps Managed Environment."
  value       = module.managedenvironment.storage_access_keys
  sensitive   = true
}
