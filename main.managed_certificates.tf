module "managed_certificates" {
  source   = "./modules/managed_certificates"
  for_each = var.managed_certificates

  location                  = each.value.location
  name                      = each.value.name
  parent_id                 = azapi_resource.this_environment.id
  domain_control_validation = each.value.domain_control_validation
  enable_telemetry          = var.enable_telemetry
  subject_name              = each.value.subject_name
  tags                      = each.value.tags
}
