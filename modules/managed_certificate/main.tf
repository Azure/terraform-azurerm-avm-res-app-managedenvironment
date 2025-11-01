resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.managed_environment.resource_id
  type      = "Microsoft.App/managedEnvironments/managedCertificates@2025-01-01"
  body = {
    properties = {
      subjectName             = var.subject_name
      domainControlValidation = var.domain_control_validation
    }
  }
  schema_validation_enabled = true
  tags                      = var.tags

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
