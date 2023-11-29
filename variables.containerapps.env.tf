variable "name" {
  type        = string
  description = "Name for the resource."
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Custom tags to apply to the resource."
  default     = {}
}

variable "log_analytics_workspace_customer_id" {
  type        = string
  description = "Customer ID for Log Analytics workspace."
  default     = null
}

variable "log_analytics_workspace_destination" {
  type        = string
  description = "Destination for Log Analytics (options: 'log-analytics', 'azuremonitor', 'none')."
  default     = "log-analytics"

  validation {
    condition     = contains(["log-analytics", "azure-monitor", "none"], var.log_analytics_workspace_destination)
    error_message = "Invalid value for log_analytics_workspace_destination. Valid options are 'log-analytics', 'azure-monitor', or 'none'."
  }
}

variable "log_analytics_workspace_primary_shared_key" {
  type        = string
  description = "Primary shared key for Log Analytics."
  default     = null
}

variable "custom_domain_certificate_password" {
  type        = string
  description = "Certificate password for custom domain."
  default     = null
}

variable "custom_domain_dns_suffix" {
  type        = string
  description = "DNS suffix for custom domain."
  default     = null
}

variable "instrumentation_key" {
  type        = string
  description = "Instrumentation key for Dapr AI."
  default     = null
}

variable "peer_authentication_enabled" {
  type        = bool
  description = "Enable peer authentication (Mutual TLS)."
  default     = false
}

variable "vnet_subnet_id" {
  type        = string
  description = "ID of the VNet subnet."
  default     = null
}

variable "vnet_internal_only" {
  type        = bool
  description = "Restrict access to internal resources within VNet."
  default     = false
}

variable "workload_profiles_enabled" {
  type        = bool
  description = "Whether to use workload profiles, this will create the default Consumption Plan, for dedicated plans use `workload_profiles`"
  default     = false
}
variable "workload_profiles" {
  type = list(object({
    name                = string
    workloadProfileType = string
    minimumCount        = optional(number, 3)
    maximumCount        = optional(number, 5)
  }))
  description = <<DESCRIPTION
This lists the workload profiles that will be configured for the Managed Environment.
This is in addition to the default Consumpion Plan workload profile.

- `name` - the name of the workload profile.
- `workloadProfileType` - workload profile type, this determines the amount of compute and memory resource available to the container apps deployed in an environment.
- `minimiumCount` - the minimum number of instances that must be deployed.
- `maximiumCount` - the maximum number of instances that may be deployed.
DESCRIPTION
  default     = []
  validation {
    condition     = var.workload_profiles == null ? true : can([for wp in var.workload_profiles : regex("^[a-zA-Z][a-zA-Z0-9_-]{0,14}[a-zA-Z0-9]$", wp.name)])
    error_message = "Invalid value for workload_profile_name. It must start with a letter, contain only letters, numbers, underscores, or dashes, and not end with an underscore or dash. Maximum 15 characters."
  }
  validation {
    condition     = var.workload_profiles == null ? true : can([for wp in var.workload_profiles : index(["D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], wp.workloadProfileType) >= 0])
    error_message = "Invalid value for workload_profile_type. Valid options are 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32'."
  }
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone-redundancy for the resource, this feature requires supplying an available subnet via `vnet_subnet_id`."
  default     = false
}
