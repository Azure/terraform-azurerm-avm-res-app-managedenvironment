module "certificate" {
  source   = "./modules/certificate"
  for_each = var.certificates

  location             = var.location
  managed_environment  = { resource_id = azapi_resource.this_environment.id }
  name                 = each.key
  certificate_password = each.value.certificate_password
  certificate_value    = each.value.certificate_value
  key_vault_identity   = each.value.key_vault_identity
  key_vault_url        = each.value.key_vault_url
  tags                 = var.tags
  timeouts             = each.value.timeouts
}
