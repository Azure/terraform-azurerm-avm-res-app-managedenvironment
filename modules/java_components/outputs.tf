output "ingress_fqdn" {
  description = "Hostname of the Java Component endpoint"
  value       = try(azapi_resource.this.output.properties.ingress.fqdn, null)
}

output "name" {
  description = "The name of the created resource."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The ID of the created resource."
  value       = azapi_resource.this.id
}
