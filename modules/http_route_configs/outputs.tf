output "fqdn" {
  description = "FQDN of the route resource."
  value       = try(azapi_resource.this.output.properties.fqdn, null)
}

output "name" {
  description = "The name of the created resource."
  value       = azapi_resource.this.name
}

output "provisioning_errors" {
  description = "List of errors when trying to reconcile http routes"
  value       = try(azapi_resource.this.output.properties.provisioningErrors, [])
}

output "resource_id" {
  description = "The ID of the created resource."
  value       = azapi_resource.this.id
}
