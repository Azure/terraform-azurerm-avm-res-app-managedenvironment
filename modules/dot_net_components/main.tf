resource "azapi_resource" "this" {
  name                  = var.name
  parent_id             = var.parent_id
  type                  = "Microsoft.App/managedEnvironments/dotNetComponents@2025-10-02-preview"
  body                  = local.resource_body
  replace_triggers_refs = ["properties.componentType"]
  response_export_values = [
  ]
}
