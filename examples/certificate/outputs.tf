output "certificate_resource_ids" {
  description = "Map of certificate names to their resource IDs"
  value       = module.managedenvironment.certificate_resource_ids
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault (for certificate storage)"
  value       = azapi_resource.key_vault.id
}

output "managed_environment_id" {
  description = "The resource ID of the Container Apps Managed Environment"
  value       = module.managedenvironment.resource_id
}

output "managed_identity_id" {
  description = "The resource ID of the managed identity (for Key Vault access)"
  value       = azapi_resource.user_assigned_identity.id
}
