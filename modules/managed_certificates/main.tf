resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.App/managedEnvironments/managedCertificates@2025-10-02-preview"
  body      = local.resource_body
  replace_triggers_refs = [
    "properties.subjectName",
    "properties.domainControlValidation",
  ]
  response_export_values = [
    "properties.error",
    "properties.validationToken",
  ]
  tags = var.tags
}
