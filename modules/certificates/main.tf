resource "azapi_resource" "this" {
  location            = var.location
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.app_managed_environments_certificates
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.app_managed_environments_certificates) > 0 ? var.ignore_body_changes.app_managed_environments_certificates : null
  replace_triggers_refs = [
    "properties.certificateKeyVaultProperties.keyVaultUrl",
    "properties.certificateKeyVaultProperties.identity",
  ]
  response_export_values = [
    "properties.deploymentErrors",
    "properties.expirationDate",
    "properties.issueDate",
    "properties.issuer",
    "properties.publicKeyHash",
    "properties.subjectAlternativeNames",
    "properties.subjectName",
    "properties.thumbprint",
    "properties.valid",
  ]
  retry = var.retry
  sensitive_body = {
    properties = {
      password = var.password
      value    = var.value
    }
  }
  sensitive_body_version = {
    "properties.password" = var.password_version
    "properties.value"    = var.value_version
  }
  tags = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
