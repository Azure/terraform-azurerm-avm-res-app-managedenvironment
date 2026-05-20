resource "azapi_resource" "this" {
  name                  = var.name
  parent_id             = var.parent_id
  type                  = "Microsoft.App/managedEnvironments/javaComponents@2025-10-02-preview"
  body                  = local.resource_body
  replace_triggers_refs = ["properties.componentType"]
  response_export_values = [
    "properties.ingress.fqdn",
  ]
  # Disabled because the body contains a discriminated object type whose
  # discriminator property value is unknown at validate time.
  schema_validation_enabled = false
}
