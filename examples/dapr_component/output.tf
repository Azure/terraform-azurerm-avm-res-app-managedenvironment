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
