resource "azapi_resource" "this_environment" {
  location  = var.location
  name      = var.name
  parent_id = local.parent_id
  type      = "Microsoft.App/managedEnvironments@2025-02-02-preview"
  body = {
    properties = local.container_app_environment_properties
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "identity",
    "properties.customDomainConfiguration",
    "properties.daprAIInstrumentationKey",
    "properties.defaultDomain",
    "properties.infrastructureResourceGroup",
    "properties.dockerBridgeCidr",
    "properties.platformReservedCidr",
    "properties.platformReservedDnsIP",
    "properties.staticIp",
  ]
  schema_validation_enabled = true
  sensitive_body = {
    properties = local.container_app_environment_sensitive_properties
  }
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
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
