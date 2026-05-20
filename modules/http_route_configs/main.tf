resource "azapi_resource" "this" {
  name                 = var.name
  parent_id            = var.parent_id
  type                 = "Microsoft.App/managedEnvironments/httpRouteConfigs@2025-10-02-preview"
  body                 = local.resource_body
  ignore_null_property = true
  response_export_values = [
    "properties.fqdn",
    "properties.provisioningErrors",
  ]
}
