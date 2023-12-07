variable "name" {
  type        = string
  description = "Name for the resource."
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "custom_domain_certificate_password" {
  type        = string
  default     = null
  description = "Certificate password for custom domain."
}

variable "custom_domain_dns_suffix" {
  type        = string
  default     = null
  description = "DNS suffix for custom domain."
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "infrastructure_resource_group_name" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources. 
If a subnet ID is provided, this resource group will be created in the same subscription as the subnet.
If not specified, then one will be generated automatically, in the form ``ME_<app_managed_environment_name>_<resource_group>_<location>``.
DESCRIPTION
}

variable "instrumentation_key" {
  type        = string
  default     = null
  description = "Instrumentation key for Dapr AI."
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  default     = {}
  description = "The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."
  nullable    = false

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "log_analytics_workspace_customer_id" {
  type        = string
  default     = null
  description = "Customer ID for Log Analytics workspace."
}

variable "log_analytics_workspace_destination" {
  type        = string
  default     = "log-analytics"
  description = "Destination for Log Analytics (options: 'log-analytics', 'azuremonitor', 'none')."

  validation {
    condition     = contains(["log-analytics", "azure-monitor", "none"], var.log_analytics_workspace_destination)
    error_message = "Invalid value for log_analytics_workspace_destination. Valid options are 'log-analytics', 'azure-monitor', or 'none'."
  }
}

variable "log_analytics_workspace_primary_shared_key" {
  type        = string
  default     = null
  description = "Primary shared key for Log Analytics."
}

variable "peer_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable peer authentication (Mutual TLS)."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Custom tags to apply to the resource."
}

variable "vnet_internal_only" {
  type        = bool
  default     = false
  description = "Restrict access to internal resources within VNet."
}

variable "vnet_subnet_id" {
  type        = string
  default     = null
  description = "ID of the VNet subnet."
}

variable "workload_profiles" {
  type = list(object({
    name                = string
    workloadProfileType = string
    minimumCount        = optional(number, 3)
    maximumCount        = optional(number, 5)
  }))
  default     = []
  description = <<DESCRIPTION
This lists the workload profiles that will be configured for the Managed Environment.
This is in addition to the default Consumpion Plan workload profile.

- `name` - the name of the workload profile.
- `workloadProfileType` - workload profile type, this determines the amount of compute and memory resource available to the container apps deployed in an environment.
- `minimiumCount` - the minimum number of instances that must be deployed.
- `maximiumCount` - the maximum number of instances that may be deployed.
DESCRIPTION

  validation {
    condition     = var.workload_profiles == null ? true : can([for wp in var.workload_profiles : regex("^[a-zA-Z][a-zA-Z0-9_-]{0,14}[a-zA-Z0-9]$", wp.name)])
    error_message = "Invalid value for workload_profile_name. It must start with a letter, contain only letters, numbers, underscores, or dashes, and not end with an underscore or dash. Maximum 15 characters."
  }
  validation {
    condition     = var.workload_profiles == null ? true : can([for wp in var.workload_profiles : index(["D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], wp.workloadProfileType) >= 0])
    error_message = "Invalid value for workload_profile_type. Valid options are 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32'."
  }
}

variable "workload_profiles_enabled" {
  type        = bool
  default     = false
  description = "Whether to use workload profiles, this will create the default Consumption Plan, for dedicated plans use `workload_profiles`"
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = false
  description = "Enable zone-redundancy for the resource, this feature requires supplying an available subnet via `vnet_subnet_id`."
}
