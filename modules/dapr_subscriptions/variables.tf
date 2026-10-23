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

variable "bulk_subscribe" {
  type = object({
    enabled               = optional(bool)
    max_await_duration_ms = optional(number)
    max_messages_count    = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Bulk subscription options

- `enabled` - Enable bulk subscription
- `max_await_duration_ms` - Maximum duration in milliseconds to wait before a bulk message is sent to the app.
- `max_messages_count` - Maximum number of messages to deliver in a bulk message.

DESCRIPTION
}

variable "dead_letter_topic" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Deadletter topic name
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
    app_managed_environments_dapr_subscriptions = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Paths in the resource's `body` whose changes the AzAPI provider ignores. Prefer Terraform's `lifecycle.ignore_changes` when the paths are static; use this variable when the paths must be derived from variables or other non-static values.

Paths use dot notation, for example `properties.sku.name`. Individual list items cannot be targeted — ignore the whole list property instead. Configuration changes at an ignored path are **not** sent to Azure until that path is removed from the list.

Supplying a non-empty value requires Terraform 1.11 or later, because `ignore_body_changes` is a write-only argument. Changes take effect only after an apply, because the value is held in provider-private state.

- `app_managed_environments_dapr_subscriptions` - Ignored body paths for the Dapr subscription.
DESCRIPTION
  nullable    = false
}

variable "metadata" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
Subscription metadata
DESCRIPTION
}

variable "pubsub_name" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Dapr PubSub component name
DESCRIPTION
}

variable "resource_types" {
  type = object({
    app_managed_environments_dapr_subscriptions = optional(string, "Microsoft.App/managedEnvironments/daprSubscriptions@2025-10-02-preview")
  })
  default     = {}
  description = <<DESCRIPTION
Override the AzAPI `<provider>/<resource>@<api-version>` string used by this module. The key defaults to a tested value. Useful when targeting a sovereign cloud with older API versions, or when opting into a newer preview API.

- `app_managed_environments_dapr_subscriptions` - The Dapr subscription.
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

variable "routes" {
  type = object({
    default = optional(string)
    rules = optional(list(object({
      match = optional(string)
      path  = optional(string)
    })))
  })
  default     = null
  description = <<DESCRIPTION
Subscription routes

- `default` - The default path to deliver events that do not match any of the rules.
- `rules` - The list of Dapr PubSub Event Subscription Route Rules.

DESCRIPTION
}

variable "scopes" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
Application scopes to restrict the subscription to specific apps.
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

variable "topic" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Topic name
DESCRIPTION
}
