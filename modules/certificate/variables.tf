variable "location" {
  type        = string
  description = "The Azure region where the certificate resource should be created."
  nullable    = false
}

variable "managed_environment" {
  type = object({
    resource_id = string
  })
  description = "The managed environment resource."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the certificate resource."
  nullable    = false
}

variable "certificate_password" {
  type        = string
  default     = null
  description = "The password for the certificate (WriteOnly). Required when using direct certificate upload."
  sensitive   = true
}

variable "certificate_value" {
  type        = string
  default     = null
  description = "The PFX or PEM blob for the certificate (WriteOnly). Required when using direct certificate upload."
  sensitive   = true
}

variable "key_vault_identity" {
  type        = string
  default     = null
  description = "Resource ID of a managed identity to authenticate with Azure Key Vault, or 'System' to use a system-assigned identity. Required when using Key Vault reference."
}

variable "key_vault_url" {
  type        = string
  default     = null
  description = "URL pointing to the Azure Key Vault secret that holds the certificate. Required when using Key Vault reference."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
 - `create` - (Defaults to 30 minutes) Used when creating the certificate.
 - `delete` - (Defaults to 30 minutes) Used when deleting the certificate.
 - `read` - (Defaults to 5 minutes) Used when retrieving the certificate.
 - `update` - (Defaults to 30 minutes) Used when updating the certificate.
DESCRIPTION
}
