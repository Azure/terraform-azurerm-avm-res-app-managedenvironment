variable "certificates" {
  type = map(object({
    certificate_key_vault_properties = optional(object({
      identity      = optional(string)
      key_vault_url = optional(string)
    }))
    location         = string
    name             = string
    password         = optional(string)
    password_version = optional(number)
    tags             = optional(map(string))
    value            = optional(any)
    value_version    = optional(number)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of certificates to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each certificate supports the following:

- `name` - (Required) The name of the certificate resource.
- `location` - (Required) The location for the certificate resource.
- `tags` - (Optional) Tags to apply to the certificate resource.
- `password` - (Optional) The certificate password.
- `password_version` - (Optional) Version tracker for `password`. Must be set when `password` is provided.
- `value` - (Optional) The PFX or PEM certificate blob.
- `value_version` - (Optional) Version tracker for `value`. Must be set when `value` is provided.

`certificate_key_vault_properties` supports the following:

- `identity` - (Optional) Resource ID of a managed identity to authenticate with Azure Key Vault, or `System` to use a system-assigned identity.
- `key_vault_url` - (Optional) URL pointing to the Azure Key Vault secret that holds the certificate.
DESCRIPTION
}
