# dapr_subscriptions submodule

Manages a Dapr pub/sub topic subscription for a Container Apps Managed Environment.

```hcl
module "dapr_subscriptions" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/dapr_subscriptions"
  version   = "<version>"

  name      = "my-subscription"
  parent_id = "/subscriptions/.../managedEnvironments/my-env"
  pubsub_name = "my-pubsub"
  topic       = "orders"
  bulk_subscribe = { enabled = false }
  routes = { default = "/orders" }
}
```
