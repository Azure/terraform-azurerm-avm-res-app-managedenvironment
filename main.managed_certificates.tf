module "managed_certificates" {
  source   = "./modules/managed_certificates"
  for_each = var.managed_certificates

  location                  = each.value.location
  name                      = each.value.name
  parent_id                 = azapi_resource.this.id
  domain_control_validation = each.value.domain_control_validation
  enable_telemetry          = var.enable_telemetry
  ignore_body_changes       = var.ignore_body_changes.app_managed_environments_managed_certificates
  resource_types            = var.resource_types.app_managed_environments_managed_certificates
  retry                     = var.retry
  subject_name              = each.value.subject_name
  tags                      = each.value.tags
  timeouts                  = var.timeouts
}
