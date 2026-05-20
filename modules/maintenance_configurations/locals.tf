locals {
  resource_body = {
    name = var.name
    properties = {
      scheduledEntries = var.scheduled_entries == null ? null : [for item in var.scheduled_entries : item == null ? null : {
        durationHours = item.duration_hours
        startHourUtc  = item.start_hour_utc
        weekDay       = item.week_day
      }]
    }
  }
}
