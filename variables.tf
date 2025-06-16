variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the Container Apps Managed Environment."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Container App Environment is to be created. Changing this forces a new resource to be created."
  nullable    = false
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

variable "dapr_application_insights_connection_string" {
  type        = string
  default     = null
  description = "Application Insights connection string used by Dapr to export Service to Service communication telemetry."
  sensitive   = true
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

variable "infrastructure_subnet_id" {
  type        = string
  default     = null
  description = "The existing Subnet to use for the Container Apps Control Plane. **NOTE:** The Subnet must have a `/21` or larger address space."
}

variable "internal_load_balancer_enabled" {
  type        = bool
  default     = false
  description = "Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. **Note:** can only be set to `true` if `infrastructure_subnet_id` is specified."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "log_analytics_workspace_customer_id" {
  type        = string
  default     = null
  description = "The ID for the Log Analytics Workspace to link this Container Apps Managed Environment to."
}

variable "log_analytics_workspace_destination" {
  type        = string
  default     = "log-analytics"
  description = "Destination for Log Analytics (options: 'log-analytics', 'azure-monitor', 'none')."

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

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
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
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the container app environment. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "storages" {
  type = map(object({
    access_key   = string
    access_mode  = string
    account_name = string
    share_name   = string
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
 - `access_key` - (Required) The Storage Account Access Key.
 - `access_mode` - (Required) The access mode to connect this storage to the Container App. Possible values include `ReadOnly` and `ReadWrite`. Changing this forces a new resource to be created.
 - `account_name` - (Required) The Azure Storage Account in which the Share to be used is located. Changing this forces a new resource to be created.
 - `share_name` - (Required) The name of the Azure Storage Share to use. Changing this forces a new resource to be created.

 ---
 `timeouts` block supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Container App Environment Storage.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App Environment Storage.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App Environment Storage.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App Environment Storage.

DESCRIPTION
  nullable    = false
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
 - `create` - (Defaults to 30 minutes) Used when creating the Container App Environment.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App Environment.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App Environment.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App Environment.
DESCRIPTION
}

variable "workload_profile" {
  type = set(object({
    maximum_count         = optional(number)
    minimum_count         = optional(number)
    name                  = string
    workload_profile_type = string
  }))
  default     = []
  description = <<DESCRIPTION

This lists the workload profiles that will be configured for the Managed Environment.
This is in addition to the default Consumption Plan workload profile.

 - `maximum_count` - (Optional) The maximum number of instances of workload profile that can be deployed in the Container App Environment.  Required for Dedicated profile types.
 - `minimum_count` - (Optional) The minimum number of instances of workload profile that can be deployed in the Container App Environment.  Required for Dedicated profile types.
 - `name` - (Required) The name of the workload profile.
 - `workload_profile_type` - (Required) Workload profile type for the workloads to run on. Possible values include `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`.

Examples:

```hcl
  # this creates a Consumption workload profile:
  workload_profile = [{
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }]

  # this creates a Dedicated workload profile, in this scenario a consumption profile is automatically created by the Container Apps service (or can be specified).
  workload_profile = [{
    name                  = "Dedicated"
    workload_profile_type = "D4"
    maximum_count         = 3
    minimum_count         = 1
  }]

  # workload profiles can also be not specified, in which case a Consumption Only plan is created, without workload profiles.
```

DESCRIPTION
  nullable    = false

  validation {
    condition     = var.workload_profile == null ? true : can([for wp in var.workload_profile : regex("^[a-zA-Z][a-zA-Z0-9_-]{0,14}[a-zA-Z0-9]$", wp.name)])
    error_message = "Invalid value for workload_profile_name. It must start with a letter, contain only letters, numbers, underscores, or dashes, and not end with an underscore or dash. Maximum 15 characters."
  }
  validation {
    condition     = var.workload_profile == null ? true : can([for wp in var.workload_profile : index(["Consumption", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], wp.workload_profile_type) >= 0])
    error_message = "Invalid value for workload_profile_type. Valid options are 'Consumption', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32'."
  }
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Should the Container App Environment be created with Zone Redundancy enabled? Defaults to `false`. Changing this forces a new resource to be created."
}
