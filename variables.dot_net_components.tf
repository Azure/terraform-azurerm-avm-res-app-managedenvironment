variable "dot_net_components" {
  type = map(object({
    component_type = optional(any)
    configurations = optional(list(object({
      property_name = optional(string)
      value         = optional(string)
    })))
    name = string
    service_binds = optional(list(object({
      name       = optional(string)
      service_id = optional(string)
    })))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of .NET components to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each .NET component supports the following:

- `name` - (Required) The name of the .NET component resource.
- `component_type` - (Optional) The .NET component type.
- `configurations` - (Optional) Configuration properties for the .NET component.
- `service_binds` - (Optional) Service bindings for the .NET component.
DESCRIPTION
}
