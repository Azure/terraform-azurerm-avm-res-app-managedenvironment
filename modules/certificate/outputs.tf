output "name" {
  description = "The name of the certificate."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the certificate."
  value       = azapi_resource.this.id
}
