variable "java_components" {
  type = map(object({
    component_type = string
    configurations = optional(list(object({
      property_name = optional(string)
      value         = optional(string)
    })))
    ingress = optional(object({}))
    name    = string
    scale = optional(object({
      max_replicas = optional(number)
      min_replicas = optional(number)
    }))
    service_binds = optional(list(object({
      name       = optional(string)
      service_id = optional(string)
    })))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of Java components to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each Java component supports the following:

- `name` - (Required) The name of the Java component resource.
- `component_type` - (Required) The Java component type.
- `configurations` - (Optional) Configuration properties for the Java component.
- `ingress` - (Optional) Ingress configuration for the Java component.
- `service_binds` - (Optional) Service bindings for the Java component.

`scale` supports the following:

- `max_replicas` - (Optional) The maximum number of Java component replicas.
- `min_replicas` - (Optional) The minimum number of Java component replicas.
DESCRIPTION
}
