variable "component_type" {
  type        = string
  description = <<DESCRIPTION
The componentType of the resource.
DESCRIPTION

  validation {
    condition     = contains(["Nacos", "SpringBootAdmin", "SpringCloudConfig", "SpringCloudEureka", "SpringCloudGateway"], var.component_type)
    error_message = "component_type must be one of: [\"Nacos\", \"SpringBootAdmin\", \"SpringCloudConfig\", \"SpringCloudEureka\", \"SpringCloudGateway\"]."
  }
}

variable "name" {
  type        = string
  description = <<DESCRIPTION
The name of the resource.
DESCRIPTION
}

variable "parent_id" {
  type        = string
  description = <<DESCRIPTION
The parent resource ID for this resource.
DESCRIPTION
}

variable "configurations" {
  type = list(object({
    property_name = optional(string)
    value         = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
List of Java Components configuration properties
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module. For more information see https://aka.ms/avm/telemetryinfo.
DESCRIPTION
  nullable    = false
}

variable "ingress" {
  type        = object({})
  default     = null
  description = <<DESCRIPTION
Java Component Ingress configurations.


DESCRIPTION
}

variable "scale" {
  type = object({
    max_replicas = optional(number)
    min_replicas = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Java component scaling configurations

- `max_replicas` - Optional. Maximum number of Java component replicas
- `min_replicas` - Optional. Minimum number of Java component replicas. Defaults to 1 if not set

DESCRIPTION
}

variable "service_binds" {
  type = list(object({
    name       = optional(string)
    service_id = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
List of Java Components that are bound to the Java component
DESCRIPTION
}

variable "spring_cloud_gateway_routes" {
  type = list(object({
    filters    = optional(list(string))
    id         = string
    order      = optional(number)
    predicates = optional(list(string))
    uri        = string
  }))
  default     = null
  description = <<DESCRIPTION
Gateway route definition.

- `filters` - List of gateway filters to apply.
- `id` - ID for the route.
- `order` - Ordering of the route.
- `predicates` - List of predicates to match.
- `uri` - URI of the route.
DESCRIPTION
}
