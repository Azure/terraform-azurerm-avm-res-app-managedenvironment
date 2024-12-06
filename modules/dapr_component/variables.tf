variable "component_type" {
  type        = string
  description = "The type of the Dapr component."
}

variable "managed_environment" {
  type = object({
    resource_id = string
  })
  description = "The Dapr component resource."
}

variable "name" {
  type        = string
  description = "The name of the Dapr component."
  nullable    = false
}

variable "dapr_component_version" {
  type        = string
  default     = null
  description = "The version of the Dapr component."
}

variable "ignore_errors" {
  type        = bool
  default     = false
  description = "Whether to ignore errors for the Dapr component."
}

variable "init_timeout" {
  type        = string
  default     = null
  description = "The initialization timeout for the Dapr component."
}

variable "metadata" {
  type = list(object({
    name        = string
    secret_name = string
    value       = string
  }))
  default     = null
  description = "The metadata for the Dapr component."
}

variable "scopes" {
  type        = list(string)
  default     = []
  description = "The scopes for the Dapr component."
}

variable "secret" {
  type = set(object({
    # identity            = string
    # key_vault_secret_id = string
    name  = string
    value = string
  }))
  default     = null
  description = "The secrets for the Dapr component."
}

variable "secret_store_component" {
  type        = string
  default     = null
  description = "The secret store component for the Dapr component."
}

variable "timeouts" {
  type = object({
    create = string
    delete = string
    read   = string
  })
  default     = null
  description = "The timeouts for creating, reading, and deleting the Dapr component."
}
