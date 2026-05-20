output "deployment_errors" {
  description = "Any errors that occurred during deployment or deployment validation"
  value       = try(azapi_resource.this.output.properties.deploymentErrors, null)
}

output "expiration_date" {
  description = "Certificate expiration date."
  value       = try(azapi_resource.this.output.properties.expirationDate, null)
}

output "issue_date" {
  description = "Certificate issue Date."
  value       = try(azapi_resource.this.output.properties.issueDate, null)
}

output "issuer" {
  description = "Certificate issuer."
  value       = try(azapi_resource.this.output.properties.issuer, null)
}

output "name" {
  description = "The name of the created resource."
  value       = azapi_resource.this.name
}

output "public_key_hash" {
  description = "Public key hash."
  value       = try(azapi_resource.this.output.properties.publicKeyHash, null)
}

output "resource_id" {
  description = "The ID of the created resource."
  value       = azapi_resource.this.id
}

output "subject_alternative_names" {
  description = "Subject alternative names the certificate applies to."
  value       = try(azapi_resource.this.output.properties.subjectAlternativeNames, [])
}

output "subject_name" {
  description = "Subject name of the certificate."
  value       = try(azapi_resource.this.output.properties.subjectName, null)
}

output "thumbprint" {
  description = "Certificate thumbprint."
  value       = try(azapi_resource.this.output.properties.thumbprint, null)
}

output "valid" {
  description = "Is the certificate valid?."
  value       = try(azapi_resource.this.output.properties.valid, null)
}
