variable "dapr_components" {
  type = map(object({
    component_type         = string
    ignore_errors          = optional(bool, true)
    init_timeout           = optional(string)
    secret_store_component = optional(string)
    scopes                 = optional(list(string))
    version                = string
    metadata = optional(list(object({
      name        = string
      secret_name = optional(string)
      value       = optional(string)
    })))
    secret = optional(set(object({
      name  = string
      value = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<-EOT
 - `component_type` - (Required) The Dapr Component Type. For example `state.azure.blobstorage`. Changing this forces a new resource to be created.
 
 - `ignore_errors` - (Optional) Should the Dapr sidecar to continue initialisation if the component fails to load. Defaults to `false`
 - `init_timeout` - (Optional) The timeout for component initialisation as a `ISO8601` formatted string. e.g. `5s`, `2h`, `1m`. Defaults to `5s`.
 - `secret_store_component` - (Optional) Name of a Dapr component to retrieve component secrets from.
 - `scopes` - (Optional) A list of scopes to which this component applies.
 - `version` - (Required) The version of the component.

 ---
 `metadata` block supports the following:
 
 - `name` - (Required) The name of the Metadata configuration item.
 - `secret_name` - (Optional) The name of a secret specified in the `secrets` block that contains the value for this metadata configuration item.
 - `value` - (Optional) The value for this metadata configuration item.

 ---
 `secret` block supports the following:

 - `name` - (Required) The Secret name.
 - `value` - (Required) The value for this secret.

 ---
 `timeouts` block supports the following:

 - `create` - (Defaults to 30 minutes) Used when creating the Container App Environment Dapr Component.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App Environment Dapr Component.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App Environment Dapr Component.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App Environment Dapr Component.
EOT
  nullable    = false
}
