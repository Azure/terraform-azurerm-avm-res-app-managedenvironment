module "managed_certificate" {
  source   = "./modules/managed_certificate"
  for_each = var.managed_certificates

  location                  = var.location
  managed_environment       = { resource_id = azapi_resource.this_environment.id }
  name                      = each.key
  subject_name              = each.value.subject_name
  domain_control_validation = each.value.domain_control_validation
  tags                      = var.tags
  timeouts                  = each.value.timeouts
}
