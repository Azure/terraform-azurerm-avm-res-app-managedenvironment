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

variable "custom_domains" {
  type = list(object({
    binding_type   = optional(any)
    certificate_id = optional(string)
    name           = string
  }))
  default     = null
  description = <<DESCRIPTION
Custom domain bindings for Http Routes' hostnames.
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

variable "rules" {
  type = list(object({
    description = optional(string)
    routes = optional(list(object({
      action = optional(object({
        prefix_rewrite = optional(string)
      }))
      match = optional(object({
        case_sensitive        = optional(bool)
        path                  = optional(string)
        path_separated_prefix = optional(string)
        prefix                = optional(string)
      }))
    })))
    targets = optional(list(object({
      container_app = string
      label         = optional(string)
      revision      = optional(string)
      weight        = optional(number)
    })))
  }))
  default     = null
  description = <<DESCRIPTION
Routing Rules for the Http Route resource.
DESCRIPTION
}
