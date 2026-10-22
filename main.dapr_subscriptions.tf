module "dapr_subscriptions" {
  source   = "./modules/dapr_subscriptions"
  for_each = var.dapr_subscriptions

  location            = var.location
  name                = each.value.name
  parent_id           = azapi_resource.this.id
  bulk_subscribe      = each.value.bulk_subscribe
  dead_letter_topic   = each.value.dead_letter_topic
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.app_managed_environments_dapr_subscriptions
  metadata            = each.value.metadata
  pubsub_name         = each.value.pubsub_name
  resource_types      = var.resource_types.app_managed_environments_dapr_subscriptions
  retry               = var.retry
  routes              = each.value.routes
  scopes              = each.value.scopes
  timeouts            = var.timeouts
  topic               = each.value.topic
}
