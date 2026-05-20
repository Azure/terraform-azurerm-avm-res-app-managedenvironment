output "error" {
  description = "Any error occurred during the certificate provision."
  value       = try(azapi_resource.this.output.properties.error, null)
}

output "name" {
  description = "The name of the created resource."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The ID of the created resource."
  value       = azapi_resource.this.id
}

output "validation_token" {
  description = "A TXT token used for DNS TXT domain control validation when issuing this type of managed certificates."
  value       = try(azapi_resource.this.output.properties.validationToken, null)
}
