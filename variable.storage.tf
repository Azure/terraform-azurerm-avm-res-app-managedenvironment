variable "storages" {
  type = map(object({
    access_key   = string
    access_mode  = string
    account_name = string
    share_name   = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `access_key` - (Required) The Storage Account Access Key.
 - `access_mode` - (Required) The access mode to connect this storage to the Container App. Possible values include `ReadOnly` and `ReadWrite`. Changing this forces a new resource to be created.
 - `account_name` - (Required) The Azure Storage Account in which the Share to be used is located. Changing this forces a new resource to be created.
 - `share_name` - (Required) The name of the Azure Storage Share to use. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Container App Environment Storage.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App Environment Storage.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App Environment Storage.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App Environment Storage.

EOT
  nullable    = false
}
