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
This variable controls whether or not telemetry is enabled for the module. For more information see https://aka.ms/avm/telemetryinfo.
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

variable "topic" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Topic name
DESCRIPTION
}
