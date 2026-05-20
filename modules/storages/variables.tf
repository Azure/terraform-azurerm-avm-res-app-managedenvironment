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

variable "account_key" {
  type        = string
  ephemeral   = true
  default     = null
  description = <<DESCRIPTION
Storage account key for azure file.
DESCRIPTION
}

variable "account_key_version" {
  type        = number
  default     = null
  description = <<DESCRIPTION
Version tracker for account_key. Must be set when account_key is provided.
DESCRIPTION

  validation {
    condition     = var.account_key == null || var.account_key_version != null
    error_message = "When account_key is set, account_key_version must also be set."
  }
}

variable "azure_file" {
  type = object({
    access_mode = optional(any)
    account_key = optional(string)
    account_key_vault_properties = optional(object({
      identity      = optional(string)
      key_vault_url = optional(string)
    }))
    account_name = optional(string)
    share_name   = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Azure file properties

- `access_mode` - Access mode for storage
- `account_key` - Storage account key for azure file.
- `account_key_vault_properties` - Storage account key stored as an Azure Key Vault secret.
  - `identity` - Resource ID of a managed identity to authenticate with Azure Key Vault, or System to use a system-assigned identity.
  - `key_vault_url` - URL pointing to the Azure Key Vault secret.
- `account_name` - Storage account name for azure file.
- `share_name` - Azure file share name.

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

variable "nfs_azure_file" {
  type = object({
    access_mode = optional(any)
    server      = optional(string)
    share_name  = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
NFS Azure file properties

- `access_mode` - Access mode for storage
- `server` - Server for NFS azure file. Specify the Azure storage account server address.
- `share_name` - NFS Azure file share name.

DESCRIPTION
}
