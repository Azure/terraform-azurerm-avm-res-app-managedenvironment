# Ephemeral variables and version trackers

# Log Analytics backward-compat variables

# AVM interface variables

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

variable "app_insights_configuration" {
  type = object({
    connection_string = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
THIS IS A VARIABLE USED FOR A PREVIEW SERVICE/FEATURE, MICROSOFT MAY NOT PROVIDE SUPPORT FOR THIS, PLEASE CHECK THE PRODUCT DOCS FOR CLARIFICATION

Environment level Application Insights configuration. Supply the connection string via the ephemeral `connection_string` variable.

- `connection_string` - Application Insights connection string (informational only; supply the value via the ephemeral `connection_string` variable).

DESCRIPTION
}

variable "app_logs_configuration" {
  type = object({
    destination = optional(string)
    log_analytics_configuration = optional(object({
      customer_id          = optional(string)
      dynamic_json_columns = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Cluster configuration which enables the log daemon to export app logs to configured destination.

- `destination` - Logs destination, can be `'log-analytics'`, `'azure-monitor'` or `'none'`
- `log_analytics_configuration` - Log Analytics configuration, must only be provided when destination is configured as `'log-analytics'`
  - `customer_id` - Log analytics customer id

DESCRIPTION
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
THIS IS A VARIABLE USED FOR A PREVIEW SERVICE/FEATURE, MICROSOFT MAY NOT PROVIDE SUPPORT FOR THIS, PLEASE CHECK THE PRODUCT DOCS FOR CLARIFICATION

The list of availability zones to use for the managed environment.
DESCRIPTION
}

variable "certificate_password" {
  type        = string
  ephemeral   = true
  default     = null
  description = "Certificate password for custom domain. Ephemeral — not stored in state."
}

variable "certificate_password_version" {
  type        = number
  default     = null
  description = "Version tracker for `certificate_password`. Must be set when `certificate_password` is provided."

  validation {
    condition     = var.certificate_password == null || var.certificate_password_version != null
    error_message = "When certificate_password is set, certificate_password_version must also be set."
  }
}

variable "certificate_value" {
  type        = string
  ephemeral   = true
  default     = null
  description = "PFX or PEM blob for the custom domain certificate. Ephemeral — not stored in state. Use `certificate_value_version` to track changes. Takes precedence over `custom_domain_configuration.certificate_value`."
}

variable "certificate_value_version" {
  type        = number
  default     = null
  description = "Version tracker for `certificate_value`. Must be set when `certificate_value` is provided."

  validation {
    condition     = var.certificate_value == null || var.certificate_value_version != null
    error_message = "When certificate_value is set, certificate_value_version must also be set."
  }
}

variable "connection_string" {
  type        = string
  ephemeral   = true
  default     = null
  description = "Application Insights connection string for `app_insights_configuration`. Ephemeral — not stored in state. Use `connection_string_version` to track changes."
}

variable "connection_string_version" {
  type        = number
  default     = null
  description = "Version tracker for `connection_string`. Must be set when `connection_string` is provided."

  validation {
    condition     = var.connection_string == null || var.connection_string_version != null
    error_message = "When connection_string is set, connection_string_version must also be set."
  }
}

variable "custom_domain_certificate_key_vault_identity" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `custom_domain_configuration.certificate_key_vault_properties.identity` instead. Will be removed in a future major release."
}

variable "custom_domain_certificate_key_vault_url" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `custom_domain_configuration.certificate_key_vault_properties.key_vault_url` instead. Will be removed in a future major release."
}

variable "custom_domain_certificate_password" {
  ephemeral   = true
  type        = string
  default     = null
  description = "DEPRECATED: Use `certificate_password` (ephemeral) + `certificate_password_version` instead. Will be removed in a future major release."
}

variable "custom_domain_certificate_value" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `custom_domain_configuration.certificate_value` instead. Will be removed in a future major release."
}

variable "custom_domain_configuration" {
  type = object({
    certificate_key_vault_properties = optional(object({
      identity      = optional(string)
      key_vault_url = optional(string)
    }))
    certificate_value = optional(any)
    dns_suffix        = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Custom domain configuration for the environment.

- `certificate_key_vault_properties` - Certificate stored in Azure Key Vault.
  - `identity` - Resource ID of a managed identity to authenticate with Azure Key Vault, or `System` to use a system-assigned identity.
  - `key_vault_url` - URL pointing to the Azure Key Vault secret that holds the certificate.
- `certificate_value` - PFX or PEM blob
- `dns_suffix` - DNS suffix for the environment domain

DESCRIPTION
}

variable "custom_domain_dns_suffix" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `custom_domain_configuration = { dns_suffix = \"...\" }` instead. Will be removed in a future major release."
}

variable "dapr_ai_connection_string" {
  type        = string
  ephemeral   = true
  default     = null
  description = "Application Insights connection string used by Dapr to export Service to Service communication telemetry. Ephemeral — not stored in state."
}

variable "dapr_ai_connection_string_version" {
  type        = number
  default     = null
  description = "Version tracker for `dapr_ai_connection_string`. Must be set when `dapr_ai_connection_string` is provided."

  validation {
    condition     = var.dapr_ai_connection_string == null || var.dapr_ai_connection_string_version != null
    error_message = "When dapr_ai_connection_string is set, dapr_ai_connection_string_version must also be set."
  }
}

variable "dapr_ai_instrumentation_key" {
  type        = string
  ephemeral   = true
  default     = null
  description = "Azure Monitor instrumentation key used by Dapr to export Service to Service communication telemetry. Ephemeral — not stored in state."
}

variable "dapr_ai_instrumentation_key_version" {
  type        = number
  default     = null
  description = "Version tracker for `dapr_ai_instrumentation_key`. Must be set when `dapr_ai_instrumentation_key` is provided."

  validation {
    condition     = var.dapr_ai_instrumentation_key == null || var.dapr_ai_instrumentation_key_version != null
    error_message = "When dapr_ai_instrumentation_key is set, dapr_ai_instrumentation_key_version must also be set."
  }
}

variable "dapr_application_insights_connection_string" {
  ephemeral   = true
  type        = string
  default     = null
  description = "DEPRECATED: Use `dapr_ai_connection_string` (ephemeral) + `dapr_ai_connection_string_version` instead. Will be removed in a future major release."
}

variable "dapr_configuration" {
  type        = object({})
  default     = null
  description = "The configuration of Dapr component."
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
A map of diagnostic settings to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.
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

variable "disk_encryption_configuration" {
  type = object({
    key_vault_configuration = optional(object({
      auth = optional(object({
        identity = optional(string)
      }))
      key_url = optional(string)
    }))
  })
  default     = null
  description = <<DESCRIPTION
THIS IS A VARIABLE USED FOR A PREVIEW SERVICE/FEATURE, MICROSOFT MAY NOT PROVIDE SUPPORT FOR THIS, PLEASE CHECK THE PRODUCT DOCS FOR CLARIFICATION

Disk encryption configuration for the Managed Environment.

- `key_vault_configuration` - Key Vault configuration for disk encryption.
  - `auth` - Authentication configuration.
    - `identity` - Resource ID of a user-assigned managed identity, or `System` to use the system-assigned identity.
  - `key_url` - Key URL (including version) pointing to a key in Key Vault.

DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "infrastructure_resource_group" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources.
If a subnet ID is provided, this resource group will be created in the same subscription as the subnet.
If not specified, then one will be generated automatically, in the form `ME_<app_managed_environment_name>_<resource_group>_<location>`.
DESCRIPTION
}

variable "infrastructure_resource_group_name" {
  type        = string
  default     = null
  description = "DEPRECATED: Renamed to `infrastructure_resource_group`. Will be removed in a future major release."
}

variable "infrastructure_subnet_id" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `vnet_configuration = { infrastructure_subnet_id = \"...\" }` instead. Will be removed in a future major release."
}

variable "ingress_configuration" {
  type = object({
    header_count_limit               = optional(number)
    request_idle_timeout             = optional(number)
    termination_grace_period_seconds = optional(number)
    workload_profile_name            = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Ingress configuration for the Managed Environment.

- `header_count_limit` - Maximum number of headers per request allowed by the ingress. Must be at least 1. Defaults to 100.
- `request_idle_timeout` - Duration (in minutes) before idle requests are timed out. Must be between 4 and 30 inclusive. Defaults to 4 minutes.
- `termination_grace_period_seconds` - Time (in seconds) to allow active connections to complete on termination. Must be between 0 and 3600. Defaults to 480 seconds.
- `workload_profile_name` - Name of the workload profile used by the ingress component.

DESCRIPTION
}

variable "internal_load_balancer_enabled" {
  type        = bool
  default     = null
  description = "DEPRECATED: Use `vnet_configuration = { internal = true }` instead. Will be removed in a future major release."
}

variable "keda_configuration" {
  type        = object({})
  default     = null
  description = "The configuration of Keda component."
}

variable "key" {
  type        = string
  ephemeral   = true
  default     = null
  description = "DataDog API key for `open_telemetry_configuration.destinations_configuration.data_dog_configuration`. Ephemeral — not stored in state. Use `key_version` to track changes."
}

variable "key_version" {
  type        = number
  default     = null
  description = "Version tracker for `key`. Must be set when `key` is provided."

  validation {
    condition     = var.key == null || var.key_version != null
    error_message = "When key is set, key_version must also be set."
  }
}

variable "kind" {
  type        = string
  default     = null
  description = "Kind of the Managed Environment."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `"CanNotDelete"` and `"ReadOnly"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "log_analytics_workspace" {
  # wrapped as an object because: https://azure.github.io/Azure-Verified-Modules/spec/TFNFR11/
  type = object({
    resource_id = string
  })
  default     = null
  description = <<DESCRIPTION
The resource ID of the Log Analytics Workspace to link this Container Apps Managed Environment to.

This is the suggested mechanism to link a Log Analytics Workspace to a Container Apps Managed Environment, as it
avoids having to pass the primary shared key directly.

This requires at least `Microsoft.OperationalInsights/workspaces/sharedkeys/read` over the Log Analytics Workspace resource,
as the key is fetched by the module (i.e. this mirrors the behaviour of the AzureRM provider).

An alternative mechanism is to supply `shared_key` directly.

DESCRIPTION
}

variable "log_analytics_workspace_customer_id" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `app_logs_configuration.log_analytics_configuration.customer_id`, or set `log_analytics_workspace.resource_id` to auto-fetch. Will be removed in a future major release."
}

variable "log_analytics_workspace_destination" {
  type        = string
  default     = null
  description = "DEPRECATED: Use `app_logs_configuration.destination` instead. Will be removed in a future major release."
}

variable "log_analytics_workspace_primary_shared_key" {
  ephemeral   = true
  type        = string
  default     = null
  description = "DEPRECATED: Use `shared_key` (ephemeral) + `shared_key_version` instead. Will be removed in a future major release."
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

variable "open_telemetry_configuration" {
  type = object({
    destinations_configuration = optional(object({
      data_dog_configuration = optional(object({
        key  = optional(string)
        site = optional(string)
      }))
      otlp_configurations = optional(list(object({
        endpoint = optional(string)
        headers = optional(list(object({
          key   = optional(string)
          value = optional(string)
        })))
        insecure = optional(bool)
        name     = optional(string)
      })))
    }))
    logs_configuration = optional(object({
      destinations = optional(list(string))
    }))
    metrics_configuration = optional(object({
      destinations = optional(list(string))
      include_keda = optional(bool)
    }))
    traces_configuration = optional(object({
      destinations = optional(list(string))
      include_dapr = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
THIS IS A VARIABLE USED FOR A PREVIEW SERVICE/FEATURE, MICROSOFT MAY NOT PROVIDE SUPPORT FOR THIS, PLEASE CHECK THE PRODUCT DOCS FOR CLARIFICATION

Environment Open Telemetry configuration.

- `destinations_configuration` - Open telemetry destinations configuration.
  - `data_dog_configuration` - Datadog destination configuration.
    - `key` - DataDog API key (informational only; supply the value via the ephemeral `key` variable).
    - `site` - The DataDog site.
  - `otlp_configurations` - OTLP endpoint configurations.
    - `endpoint` - OTLP endpoint URL.
    - `headers` - HTTP headers for OTLP requests.
    - `insecure` - Whether the connection is insecure.
    - `name` - Name of the OTLP configuration.
- `logs_configuration` - Open telemetry logs configuration.
  - `destinations` - List of log destination names.
- `metrics_configuration` - Open telemetry metrics configuration.
  - `destinations` - List of metrics destination names.
  - `include_keda` - Include KEDA metrics.
- `traces_configuration` - Open telemetry traces configuration.
  - `destinations` - List of traces destination names.
  - `include_dapr` - Include Dapr traces.

DESCRIPTION
}

variable "parent_id" {
  type        = string
  default     = null
  description = "The parent resource ID for this resource. When provided, takes precedence over `resource_group_name`."
}

variable "peer_authentication" {
  type = object({
    mtls = optional(object({
      enabled = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Peer authentication settings for the Managed Environment.

- `mtls` - Mutual TLS authentication settings for the Managed Environment
  - `enabled` - Boolean indicating whether the mutual TLS authentication is enabled

DESCRIPTION
}

variable "peer_authentication_enabled" {
  type        = bool
  default     = null
  description = "DEPRECATED: Use `peer_authentication = { mtls = { enabled = true } }` instead. Will be removed in a future major release."
}

variable "peer_traffic_configuration" {
  type = object({
    encryption = optional(object({
      enabled = optional(bool)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Peer traffic settings for the Managed Environment.

- `encryption` - Peer traffic encryption settings for the Managed Environment
  - `enabled` - Boolean indicating whether the peer traffic encryption is enabled

DESCRIPTION
}

variable "peer_traffic_encryption_enabled" {
  type        = bool
  default     = null
  description = "DEPRECATED: Use `peer_traffic_configuration = { encryption = { enabled = true } }` instead. Will be removed in a future major release."
}

variable "public_network_access" {
  type        = any
  default     = null
  description = <<DESCRIPTION
Property to allow or block all public traffic. Allowed values: `'Enabled'`, `'Disabled'`.

**Note:** If `vnet_configuration.internal` is `true`, this module forces `'Disabled'` regardless of this setting.

DESCRIPTION
}

variable "public_network_access_enabled" {
  type        = bool
  default     = null
  description = "DEPRECATED: Use `public_network_access` (string: `\"Enabled\"` or `\"Disabled\"`) instead. Will be removed in a future major release."
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

variable "shared_key" {
  type        = string
  ephemeral   = true
  default     = null
  description = <<DESCRIPTION
Log analytics primary shared key. Ephemeral — not stored in state.

The preferred mechanism is to specify `log_analytics_workspace.resource_id`, in which case this can be left as `null`.

DESCRIPTION
}

variable "shared_key_version" {
  type        = number
  default     = null
  description = "Version tracker for `shared_key`. Must be set when `shared_key` is provided."

  validation {
    condition     = var.shared_key == null || var.shared_key_version != null
    error_message = "When shared_key is set, shared_key_version must also be set."
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
 - `create` - (Defaults to 30 minutes) Used when creating the Container App Environment.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App Environment.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App Environment.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App Environment.
DESCRIPTION
}

variable "vnet_configuration" {
  type = object({
    docker_bridge_cidr       = optional(string)
    infrastructure_subnet_id = optional(string)
    internal                 = optional(bool)
    platform_reserved_cidr   = optional(string)
    platform_reserved_dns_ip = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
VNet configuration for the Managed Environment.

- `docker_bridge_cidr` - CIDR notation IP range assigned to the Docker bridge network. Must not overlap with any other provided IP ranges.
- `infrastructure_subnet_id` - Resource ID of a subnet for infrastructure components. Must not overlap with any other provided IP ranges.
- `internal` - Boolean indicating the environment only has an internal load balancer. These environments do not have a public static IP resource. They must provide `infrastructure_subnet_id` if enabling this property.
- `platform_reserved_cidr` - IP range in CIDR notation that can be reserved for environment infrastructure IP addresses. Must not overlap with any other provided IP ranges.
- `platform_reserved_dns_ip` - An IP address from the IP range defined by `platform_reserved_cidr` that will be reserved for the internal DNS server.

DESCRIPTION
}

variable "workload_profile" {
  type = set(object({
    maximum_count         = optional(number)
    minimum_count         = optional(number)
    name                  = string
    workload_profile_type = string
  }))
  default     = null
  description = "DEPRECATED: Renamed to `workload_profiles` (list). Will be removed in a future major release."

  validation {
    condition     = var.workload_profile == null ? true : can([for wp in var.workload_profile : regex("^[a-zA-Z][a-zA-Z0-9_-]{0,13}[a-zA-Z0-9]$", wp.name)])
    error_message = "Invalid value for workload profile name. It must start with a letter, contain only letters, numbers, underscores, or dashes, and not end with an underscore or dash. Maximum 15 characters."
  }
  validation {
    condition = var.workload_profile == null ? true : alltrue([
      for wp in var.workload_profile : contains([
        "Consumption",
        "Flexible",
        "D4",
        "D8",
        "D16",
        "D32",
        "E4",
        "E8",
        "E16",
        "E32",
        "DC4",
        "DC8",
        "DC16",
        "DC32",
        "DC48",
        "DC64",
        "DC96",
        "NC24-A100",
        "NC48-A100",
        "NC96-A100",
        "Consumption-GPU-NC24-A100",
        "Consumption-GPU-NC8as-T4",
      ], wp.workload_profile_type)
    ])
    error_message = "Invalid value for workload_profile_type. Valid options are 'Consumption', 'Flexible', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32', 'DC4', 'DC8', 'DC16', 'DC32', 'DC48', 'DC64', 'DC96', 'NC24-A100', 'NC48-A100', 'NC96-A100', 'Consumption-GPU-NC24-A100', and 'Consumption-GPU-NC8as-T4'."
  }
}

variable "workload_profiles" {
  type = list(object({
    maximum_count         = optional(number)
    minimum_count         = optional(number)
    name                  = string
    workload_profile_type = string
  }))
  default     = null
  description = <<DESCRIPTION
Workload profiles configured for the Managed Environment. This is in addition to the default Consumption profile.

- `maximum_count` - (Optional) The maximum number of instances of workload profile that can be deployed in the Container App Environment. Required for Dedicated profile types.
- `minimum_count` - (Optional) The minimum number of instances of workload profile that can be deployed in the Container App Environment. Required for Dedicated profile types.
- `name` - (Required) The name of the workload profile.
- `workload_profile_type` - (Required) Workload profile type for the workloads to run on. Current documented values are `Consumption`, `Flexible`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16`, `E32`, `DC4`, `DC8`, `DC16`, `DC32`, `DC48`, `DC64`, `DC96`, `NC24-A100`, `NC48-A100`, `NC96-A100`, `Consumption-GPU-NC24-A100`, and `Consumption-GPU-NC8as-T4`.
Examples:

```hcl
  workload_profiles = [{
    name                  = "Dedicated"
    workload_profile_type = "D4"
    maximum_count         = 3
    minimum_count         = 1
  }]
```

DESCRIPTION

  validation {
    condition     = var.workload_profiles == null ? true : can([for wp in var.workload_profiles : regex("^[a-zA-Z][a-zA-Z0-9_-]{0,13}[a-zA-Z0-9]$", wp.name)])
    error_message = "Invalid value for workload profile name. It must start with a letter, contain only letters, numbers, underscores, or dashes, and not end with an underscore or dash. Maximum 15 characters."
  }
  validation {
    condition = var.workload_profiles == null ? true : alltrue([
      for wp in var.workload_profiles : contains([
        "Consumption",
        "Flexible",
        "D4",
        "D8",
        "D16",
        "D32",
        "E4",
        "E8",
        "E16",
        "E32",
        "DC4",
        "DC8",
        "DC16",
        "DC32",
        "DC48",
        "DC64",
        "DC96",
        "NC24-A100",
        "NC48-A100",
        "NC96-A100",
        "Consumption-GPU-NC24-A100",
        "Consumption-GPU-NC8as-T4",
      ], wp.workload_profile_type)
    ])
    error_message = "Invalid value for workload_profile_type. Valid options are 'Consumption', 'Flexible', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32', 'DC4', 'DC8', 'DC16', 'DC32', 'DC48', 'DC64', 'DC96', 'NC24-A100', 'NC48-A100', 'NC96-A100', 'Consumption-GPU-NC24-A100', and 'Consumption-GPU-NC8as-T4'."
  }
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = null
  description = "DEPRECATED: Renamed to `zone_redundant`. Will be removed in a future major release."
}

variable "zone_redundant" {
  type        = bool
  default     = true
  description = "(Optional) Should the Container App Environment be created with Zone Redundancy enabled? Defaults to `true`. Changing this forces a new resource to be created."
}
