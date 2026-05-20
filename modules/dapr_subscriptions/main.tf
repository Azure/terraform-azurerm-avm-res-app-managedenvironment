resource "azapi_resource" "this" {
  name                 = var.name
  parent_id            = var.parent_id
  type                 = "Microsoft.App/managedEnvironments/daprSubscriptions@2025-10-02-preview"
  body                 = local.resource_body
  ignore_null_property = true
  replace_triggers_refs = [
    "properties.pubsubName",
    "properties.topic",
  ]
  response_export_values = [
  ]
}
