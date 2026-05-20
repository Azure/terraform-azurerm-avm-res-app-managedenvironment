module "dapr_subscriptions" {
  source   = "./modules/dapr_subscriptions"
  for_each = var.dapr_subscriptions

  name              = each.value.name
  parent_id         = azapi_resource.this_environment.id
  bulk_subscribe    = each.value.bulk_subscribe
  dead_letter_topic = each.value.dead_letter_topic
  enable_telemetry  = var.enable_telemetry
  metadata          = each.value.metadata
  pubsub_name       = each.value.pubsub_name
  routes            = each.value.routes
  scopes            = each.value.scopes
  topic             = each.value.topic
}
