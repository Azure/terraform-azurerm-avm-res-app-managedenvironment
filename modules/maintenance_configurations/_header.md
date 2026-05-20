# maintenance_configurations submodule

Manages a planned maintenance window for a Container Apps Managed Environment.

```hcl
module "maintenance_configurations" {
  source    = "Azure/avm-res-app-managedenvironment/azurerm//modules/maintenance_configurations"
  version   = "<version>"

  name      = "weekly-window"
  parent_id = "/subscriptions/.../managedEnvironments/my-env"
  scheduled_entries = [{
    day_of_week      = "Monday"
    duration_in_hours = 8
    start_hour_utc   = 2
  }]
}
```
