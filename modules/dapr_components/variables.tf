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
  type        = string
  default     = null
  description = <<DESCRIPTION
Component type
DESCRIPTION
}

variable "dapr_components_version" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Component version
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

variable "ignore_errors" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
Boolean describing if the component errors are ignores
DESCRIPTION
}

variable "init_timeout" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Initialization timeout
DESCRIPTION
}

variable "metadata" {
  type = list(object({
    name       = optional(string)
    secret_ref = optional(string)
    value      = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
Component metadata
DESCRIPTION
}

variable "scopes" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
Names of container apps that can use this Dapr component
DESCRIPTION
}

variable "secret_store_component" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Name of a Dapr component to retrieve component secrets from
DESCRIPTION
}

variable "secrets" {
  type = list(object({
    identity      = optional(string)
    key_vault_url = optional(string)
    name          = optional(string)
    value         = optional(string)
  }))
  ephemeral   = true
  default     = null
  description = <<DESCRIPTION
Collection of secrets used by a Dapr component
DESCRIPTION
}

variable "secrets_version" {
  type        = number
  default     = null
  description = <<DESCRIPTION
Version tracker for secrets. Must be set when secrets is provided.
DESCRIPTION

  validation {
    condition     = var.secrets == null || var.secrets_version != null
    error_message = "When secrets is set, secrets_version must also be set."
  }
}

variable "service_component_bind" {
  type = list(object({
    metadata = optional(object({
      name  = optional(string)
      value = optional(string)
    }))
    name       = optional(string)
    service_id = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
List of container app services that are bound to the Dapr component.

- `metadata` - Optional. Metadata for the service bind.
  - `name` - Optional. Name of the metadata item.
  - `value` - Optional. Value of the metadata item.
- `name` - Optional. Name of the service bind.
- `service_id` - Optional. Service ID to bind to.
DESCRIPTION
}
