locals {
  resource_body = {
    name = var.name
    properties = {
      bulkSubscribe = var.bulk_subscribe == null ? null : {
        enabled            = var.bulk_subscribe.enabled
        maxAwaitDurationMs = var.bulk_subscribe.max_await_duration_ms
        maxMessagesCount   = var.bulk_subscribe.max_messages_count
      }
      deadLetterTopic = var.dead_letter_topic
      metadata        = var.metadata == null ? null : { for k, value in var.metadata : k => value }
      pubsubName      = var.pubsub_name
      routes = var.routes == null ? null : {
        default = var.routes.default
        rules = var.routes.rules == null ? null : [for item in var.routes.rules : item == null ? null : {
          match = item.match
          path  = item.path
        }]
      }
      scopes = var.scopes == null ? null : [for item in var.scopes : item]
      topic  = var.topic
    }
  }
}
