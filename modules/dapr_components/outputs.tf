output "deployment_errors" {
  description = "Any errors that occurred during deployment or deployment validation"
  value       = try(azapi_resource.this.output.properties.deploymentErrors, null)
}

output "name" {
  description = "The name of the created resource."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The ID of the created resource."
  value       = azapi_resource.this.id
}
