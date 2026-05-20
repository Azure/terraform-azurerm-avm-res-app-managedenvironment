module "certificates" {
  source   = "./modules/certificates"
  for_each = var.certificates

  location                         = each.value.location
  name                             = each.value.name
  parent_id                        = azapi_resource.this_environment.id
  certificate_key_vault_properties = each.value.certificate_key_vault_properties
  enable_telemetry                 = var.enable_telemetry
  password                         = each.value.password
  password_version                 = each.value.password_version
  tags                             = each.value.tags
  value                            = each.value.value
  value_version                    = each.value.value_version
}
