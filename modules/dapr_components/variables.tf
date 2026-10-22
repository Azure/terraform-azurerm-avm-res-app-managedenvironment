variable "location" {
  type        = string
  description = "The Azure region for this module's resources or telemetry deployment."
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
The resource ID of the Container Apps Managed Environment, for example `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.App/managedEnvironments/example-env`. Changing this forces a new resource to be created.
DESCRIPTION
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.App/managedEnvironments", var.parent_id))
    error_message = "`parent_id` must be a valid Container Apps Managed Environment resource ID."
  }
}

variable "component_type" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Component type
DESCRIPTION
}

variable "dapr_components_version" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Component version
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "ignore_body_changes" {
  type = object({
    app_managed_environments_dapr_components = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Paths in the resource's `body` whose changes the AzAPI provider ignores. Prefer Terraform's `lifecycle.ignore_changes` when the paths are static; use this variable when the paths must be derived from variables or other non-static values.

Paths use dot notation, for example `properties.sku.name`. Individual list items cannot be targeted — ignore the whole list property instead. Configuration changes at an ignored path are **not** sent to Azure until that path is removed from the list.

Supplying a non-empty value requires Terraform 1.11 or later, because `ignore_body_changes` is a write-only argument. Changes take effect only after an apply, because the value is held in provider-private state.

- `app_managed_environments_dapr_components` - Ignored body paths for the Dapr component.
DESCRIPTION
  nullable    = false
}

variable "ignore_errors" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
Boolean describing if the component errors are ignores
DESCRIPTION
}

variable "init_timeout" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Initialization timeout
DESCRIPTION
}

variable "metadata" {
  type = list(object({
    name       = optional(string)
    secret_ref = optional(string)
    value      = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
Component metadata
DESCRIPTION
}

variable "resource_types" {
  type = object({
    app_managed_environments_dapr_components = optional(string, "Microsoft.App/managedEnvironments/daprComponents@2025-10-02-preview")
  })
  default     = {}
  description = <<DESCRIPTION
Override the AzAPI `<provider>/<resource>@<api-version>` string used by this module. The key defaults to a tested value. Useful when targeting a sovereign cloud with older API versions, or when opting into a newer preview API.

- `app_managed_environments_dapr_components` - The Dapr component.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ContainerAppEnvironmentDisabled"])
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = {}
  description = <<DESCRIPTION
Retry configuration applied to every `azapi` resource managed by the module. By default the module retries `ContainerAppEnvironmentDisabled`, which the control plane returns until an environment that has scaled to zero finishes waking. Consumers **MAY** override any field.

- `error_message_regex`  - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `["ContainerAppEnvironmentDisabled"]`.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.

See <https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource#retry> for full semantics.
DESCRIPTION
}

variable "scopes" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
Names of container apps that can use this Dapr component
DESCRIPTION
}

variable "secret_store_component" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Name of a Dapr component to retrieve component secrets from
DESCRIPTION
}

variable "secrets" {
  type = list(object({
    identity      = optional(string)
    key_vault_url = optional(string)
    name          = optional(string)
    value         = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
Collection of secrets used by a Dapr component
DESCRIPTION
  ephemeral   = true
}

variable "secrets_version" {
  type        = number
  default     = null
  description = <<DESCRIPTION
Version tracker for secrets. Must be set when secrets is provided.
DESCRIPTION

  validation {
    condition     = var.secrets == null || var.secrets_version != null
    error_message = "When secrets is set, secrets_version must also be set."
  }
}

variable "service_component_bind" {
  type = list(object({
    metadata = optional(object({
      name  = optional(string)
      value = optional(string)
    }))
    name       = optional(string)
    service_id = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
List of container app services that are bound to the Dapr component.

- `metadata` - Optional. Metadata for the service bind.
  - `name` - Optional. Name of the metadata item.
  - `value` - Optional. Value of the metadata item.
- `name` - Optional. Name of the service bind.
- `service_id` - Optional. Service ID to bind to.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default per-operation timeouts applied to every `azapi` resource managed by the module. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read`   - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
