output "storages" {
  description = "The storage of the Container Apps Managed Environment."
  value       = module.managedenvironment.storages
}

output "storages_access_keys" {
  description = "The storage access keys for storage resources attached to the Container Apps Managed Environment."
  value       = module.managedenvironment.storage_access_keys
  sensitive   = true
}
