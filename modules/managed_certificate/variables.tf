variable "location" {
  type        = string
  description = "The Azure region where the managed certificate resource should be created."
  nullable    = false
}

variable "managed_environment" {
  type = object({
    resource_id = string
  })
  description = "The managed environment resource."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the managed certificate resource."
  nullable    = false
}

variable "subject_name" {
  type        = string
  description = "The subject name (domain name) for the certificate."
  nullable    = false
}

variable "domain_control_validation" {
  type        = string
  default     = "HTTP"
  description = "The domain control validation method. Possible values: 'CNAME', 'HTTP', 'TXT'. Defaults to 'HTTP'."
  nullable    = false

  validation {
    condition     = can(regex("^(CNAME|HTTP|TXT)$", var.domain_control_validation))
    error_message = "The domain control validation must be one of: 'CNAME', 'HTTP', 'TXT'."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
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
 - `create` - (Defaults to 30 minutes) Used when creating the managed certificate.
 - `delete` - (Defaults to 30 minutes) Used when deleting the managed certificate.
 - `read` - (Defaults to 5 minutes) Used when retrieving the managed certificate.
 - `update` - (Defaults to 30 minutes) Used when updating the managed certificate.
DESCRIPTION
}
