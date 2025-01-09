variable "access_key" {
  type        = string
  description = "The access key for the Azure file storage."
  nullable    = false
  sensitive   = true
}

variable "account_name" {
  type        = string
  description = "The account name for the Azure file storage."
  nullable    = false
}

variable "managed_environment" {
  type = object({
    resource_id = string
  })
  description = "The storage component resource."
}

variable "name" {
  type        = string
  description = "The name of the storage resource."
}

variable "share_name" {
  type        = string
  description = "The share name for the Azure file storage."
  nullable    = false
}

variable "access_mode" {
  type        = string
  default     = "ReadOnly"
  description = "The access mode for the Azure file storage."
  nullable    = false

  validation {
    condition     = can(regex("^(ReadOnly|ReadWrite)$", var.access_mode))
    error_message = "The access mode must be either 'ReadOnly' or 'ReadWrite'."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
 - `create` - (Defaults to 30 minutes) Used when creating the storage component.
 - `delete` - (Defaults to 30 minutes) Used when deleting the storage component.
 - `read` - (Defaults to 5 minutes) Used when retrieving the storage component.
 - `update` - (Defaults to 30 minutes) Used when updating the storage component.
DESCRIPTION
}
