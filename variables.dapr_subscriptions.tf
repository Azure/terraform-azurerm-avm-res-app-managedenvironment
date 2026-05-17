variable "dapr_subscriptions" {
  type = map(object({
    bulk_subscribe = optional(object({
      enabled               = optional(bool)
      max_await_duration_ms = optional(number)
      max_messages_count    = optional(number)
    }))
    dead_letter_topic = optional(string)
    metadata          = optional(map(string))
    name              = string
    pubsub_name       = optional(string)
    routes = optional(object({
      default = optional(string)
      rules = optional(list(object({
        match = optional(string)
        path  = optional(string)
      })))
    }))
    scopes = optional(list(string))
    topic  = optional(string)
  }))
  default     = {}
  description = <<DESCRIPTION
Map of Dapr subscriptions to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each Dapr subscription supports the following:

- `name` - (Required) The name of the Dapr subscription resource.
- `dead_letter_topic` - (Optional) The dead-letter topic name.
- `metadata` - (Optional) Metadata for the subscription.
- `pubsub_name` - (Optional) The Dapr PubSub component name.
- `scopes` - (Optional) Application scopes to restrict the subscription to specific apps.
- `topic` - (Optional) The topic name.

`bulk_subscribe` supports the following:

- `enabled` - (Optional) Whether bulk subscription delivery is enabled.
- `max_await_duration_ms` - (Optional) The maximum duration in milliseconds to wait before a bulk message is sent to the app.
- `max_messages_count` - (Optional) The maximum number of messages to deliver in a bulk message.

`routes` supports the following:

- `default` - (Optional) The default path to deliver events that do not match any route rules.
- `rules` - (Optional) The list of Dapr PubSub event subscription route rules.
DESCRIPTION
}
