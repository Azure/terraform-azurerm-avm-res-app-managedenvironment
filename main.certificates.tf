module "certificates" {
  source   = "./modules/certificates"
  for_each = var.certificates

  location                         = each.value.location
  name                             = each.value.name
  parent_id                        = azapi_resource.this.id
  certificate_key_vault_properties = each.value.certificate_key_vault_properties
  enable_telemetry                 = var.enable_telemetry
  ignore_body_changes              = var.ignore_body_changes.app_managed_environments_certificates
  password                         = each.value.password
  password_version                 = each.value.password_version
  resource_types                   = var.resource_types.app_managed_environments_certificates
  retry                            = var.retry
  tags                             = each.value.tags
  timeouts                         = var.timeouts
  value                            = each.value.value
  value_version                    = each.value.value_version
}
