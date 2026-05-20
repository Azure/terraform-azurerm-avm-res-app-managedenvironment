resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.App/managedEnvironments/maintenanceConfigurations@2025-10-02-preview"
  body      = local.resource_body
  response_export_values = [
  ]
}
