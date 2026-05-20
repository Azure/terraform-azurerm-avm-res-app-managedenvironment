variable "maintenance_configurations" {
  type = map(object({
    name = string
    scheduled_entries = list(object({
      duration_hours = number
      start_hour_utc = number
      week_day       = string
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of maintenance configurations to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each maintenance configuration supports the following:

- `name` - (Required) The name of the maintenance configuration resource.
- `scheduled_entries` - (Required) The list of maintenance schedules for the managed environment.
DESCRIPTION
}
