variable "storages" {
  type = map(object({
    account_key         = optional(string)
    account_key_version = optional(number)
    azure_file = optional(object({
      access_mode = optional(any)
      account_key = optional(string)
      account_key_vault_properties = optional(object({
        identity      = optional(string)
        key_vault_url = optional(string)
      }))
      account_name = optional(string)
      share_name   = optional(string)
    }))
    name = string
    nfs_azure_file = optional(object({
      access_mode = optional(any)
      server      = optional(string)
      share_name  = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of storage definitions to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each storage definition supports the following:

- `name` - (Required) The name of the storage resource.
- `account_key` - (Optional) The storage account key for the Azure file share.
- `account_key_version` - (Optional) Version tracker for `account_key`. Must be set when `account_key` is provided.

`azure_file` supports the following:

- `access_mode` - (Optional) The access mode for the Azure file share.
- `account_key` - (Optional) The storage account key for the Azure file share.
- `account_name` - (Optional) The storage account name.
- `share_name` - (Optional) The Azure file share name.

`azure_file.account_key_vault_properties` supports the following:

- `identity` - (Optional) Resource ID of a managed identity to authenticate with Azure Key Vault, or `System` to use a system-assigned identity.
- `key_vault_url` - (Optional) URL pointing to the Azure Key Vault secret that holds the storage account key.

`nfs_azure_file` supports the following:

- `access_mode` - (Optional) The access mode for the NFS Azure file share.
- `server` - (Optional) The Azure storage account server address.
- `share_name` - (Optional) The NFS Azure file share name.
DESCRIPTION
}
