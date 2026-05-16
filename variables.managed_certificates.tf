variable "managed_certificates" {
  type = map(object({
    domain_control_validation = optional(any)
    location                  = string
    name                      = string
    subject_name              = optional(string)
    tags                      = optional(map(string))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of managed certificates to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each managed certificate supports the following:

- `name` - (Required) The name of the managed certificate resource.
- `location` - (Required) The location for the managed certificate resource.
- `subject_name` - (Optional) The subject name for the certificate.
- `domain_control_validation` - (Optional) The selected domain control validation method.
- `tags` - (Optional) Tags to apply to the managed certificate resource.
DESCRIPTION
}
