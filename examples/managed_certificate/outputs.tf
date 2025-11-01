output "managed_certificate_resource_ids" {
  description = "Map of managed certificate names to their resource IDs"
  value       = module.managedenvironment.managed_certificate_resource_ids
}

output "managed_environment_id" {
  description = "The resource ID of the Container Apps Managed Environment"
  value       = module.managedenvironment.resource_id
}

output "managed_environment_default_domain" {
  description = "The default domain of the Managed Environment (for DNS configuration reference)"
  value       = module.managedenvironment.default_domain
}
