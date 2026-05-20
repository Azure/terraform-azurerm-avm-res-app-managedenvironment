variable "location" {
  type        = string
  description = <<DESCRIPTION
The location of the resource.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = <<DESCRIPTION
The name of the resource.
DESCRIPTION
}

variable "parent_id" {
  type        = string
  description = <<DESCRIPTION
The parent resource ID for this resource.
DESCRIPTION
}

variable "certificate_key_vault_properties" {
  type = object({
    identity      = optional(string)
    key_vault_url = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Properties for a certificate stored in a Key Vault.

- `identity` - Resource ID of a managed identity to authenticate with Azure Key Vault, or System to use a system-assigned identity.
- `key_vault_url` - URL pointing to the Azure Key Vault secret that holds the certificate.

DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module. For more information see https://aka.ms/avm/telemetryinfo.
DESCRIPTION
  nullable    = false
}

variable "password" {
  type        = string
  ephemeral   = true
  default     = null
  description = <<DESCRIPTION
Certificate password.
DESCRIPTION
}

variable "password_version" {
  type        = number
  default     = null
  description = <<DESCRIPTION
Version tracker for password. Must be set when password is provided.
DESCRIPTION

  validation {
    condition     = var.password == null || var.password_version != null
    error_message = "When password is set, password_version must also be set."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
(Optional) Tags of the resource.
DESCRIPTION
}

variable "value" {
  type        = any
  ephemeral   = true
  default     = null
  description = <<DESCRIPTION
PFX or PEM blob
DESCRIPTION
}

variable "value_version" {
  type        = number
  default     = null
  description = <<DESCRIPTION
Version tracker for value. Must be set when value is provided.
DESCRIPTION

  validation {
    condition     = var.value == null || var.value_version != null
    error_message = "When value is set, value_version must also be set."
  }
}
