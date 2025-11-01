output "certificate_resource_ids" {
  description = "Map of certificate names to their resource IDs"
  value       = module.managedenvironment.certificate_resource_ids
}

output "managed_environment_id" {
  description = "The resource ID of the Container Apps Managed Environment"
  value       = module.managedenvironment.resource_id
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault (for certificate storage)"
  value       = azurerm_key_vault.this.id
}

output "managed_identity_id" {
  description = "The resource ID of the managed identity (for Key Vault access)"
  value       = azurerm_user_assigned_identity.this.id
}
