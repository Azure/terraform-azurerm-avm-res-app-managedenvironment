variable "dapr_components" {
  type = map(object({
    component_type          = optional(string)
    dapr_components_version = optional(string)
    ignore_errors           = optional(bool)
    init_timeout            = optional(string)
    metadata = optional(list(object({
      name       = optional(string)
      secret_ref = optional(string)
      value      = optional(string)
    })))
    name                   = string
    scopes                 = optional(list(string))
    secret_store_component = optional(string)
    secrets = optional(list(object({
      identity      = optional(string)
      key_vault_url = optional(string)
      name          = optional(string)
      value         = optional(string)
    })))
    secrets_version = optional(number)
  }))
  default     = {}
  description = <<DESCRIPTION
Map of Dapr components to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each Dapr component supports the following:

- `name` - (Required) The name of the Dapr component resource.
- `component_type` - (Optional) The Dapr component type.
- `dapr_components_version` - (Optional) The component version.
- `ignore_errors` - (Optional) Whether component loading errors should be ignored.
- `init_timeout` - (Optional) The initialization timeout.
- `scopes` - (Optional) Names of container apps that can use this Dapr component.
- `secret_store_component` - (Optional) The name of a Dapr component to retrieve component secrets from.
- `secrets_version` - (Optional) Version tracker for `secrets`. Must be set when `secrets` is provided.

`metadata` supports the following:

- `name` - (Optional) The metadata item name.
- `secret_ref` - (Optional) A secret reference for the metadata item.
- `value` - (Optional) The metadata item value.

`secrets` supports the following:

- `identity` - (Optional) The managed identity used for Key Vault access.
- `key_vault_url` - (Optional) The Key Vault secret URL for the secret value.
- `name` - (Optional) The secret name.
- `value` - (Optional) The secret value.
DESCRIPTION
}
