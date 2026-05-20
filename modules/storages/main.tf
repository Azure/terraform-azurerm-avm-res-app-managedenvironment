resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.App/managedEnvironments/storages@2025-10-02-preview"
  body      = local.resource_body
  replace_triggers_refs = [
    "properties.azureFile.accountName",
    "properties.azureFile.shareName",
    "properties.nfsAzureFile.server",
  ]
  response_export_values = [
  ]
  sensitive_body = {
    properties = {
      azureFile = var.azure_file == null ? null : {
        accountKey = var.account_key
      }
    }
  }
  sensitive_body_version = {
    "properties.azureFile.accountKey" = var.account_key_version
  }
}
