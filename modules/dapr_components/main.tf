resource "azapi_resource" "this" {
  name                  = var.name
  parent_id             = var.parent_id
  type                  = "Microsoft.App/managedEnvironments/daprComponents@2025-10-02-preview"
  body                  = local.resource_body
  ignore_null_property  = true
  replace_triggers_refs = ["properties.componentType"]
  response_export_values = [
    "properties.deploymentErrors",
  ]
  sensitive_body = {
    properties = {
      secrets = var.secrets
    }
  }
  sensitive_body_version = {
    "properties.secrets" = var.secrets_version
  }
}
