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

variable "component_type" {
  type        = any
  default     = null
  description = <<DESCRIPTION
Type of the .NET Component.
DESCRIPTION
}

variable "configurations" {
  type = list(object({
    property_name = optional(string)
    value         = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
List of .NET Components configuration properties
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

variable "service_binds" {
  type = list(object({
    name       = optional(string)
    service_id = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
List of .NET Components that are bound to the .NET component
DESCRIPTION
}
