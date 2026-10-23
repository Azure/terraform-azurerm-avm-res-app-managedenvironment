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

- `destination` - Logs destination, can be `'log-analytics'` or `'azure-monitor'`. Omit `app_logs_configuration` entirely to disable app logs.
- `log_analytics_configuration` - Log Analytics configuration, must only be provided when destination is configured as `'log-analytics'`
  - `customer_id` - Log analytics customer id

DESCRIPTION

  validation {
    condition = var.app_logs_configuration == null || var.app_logs_configuration.destination == null || contains([
      "log-analytics",
      "azure-monitor",
    ], var.app_logs_configuration.destination)
    error_message = "app_logs_configuration.destination must be \"log-analytics\" or \"azure-monitor\". Omit app_logs_configuration to disable app logs."
  }
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
  default     = null
  description = "Certificate password for custom domain. Ephemeral — not stored in state."
  ephemeral   = true
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
  default     = null
  description = "PFX or PEM blob for the custom domain certificate. Ephemeral — not stored in state. Use `certificate_value_version` to track changes. Takes precedence over `custom_domain_configuration.certificate_value`."
  ephemeral   = true
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
  default     = null
  description = "Application Insights connection string for `app_insights_configuration`. Ephemeral — not stored in state. Use `connection_string_version` to track changes."
  ephemeral   = true
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
  type        = string
  default     = null
  description = "DEPRECATED: Use `certificate_password` (ephemeral) + `certificate_password_version` instead. Will be removed in a future major release."
  ephemeral   = true
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
  default     = null
  description = "Application Insights connection string used by Dapr to export Service to Service communication telemetry. Ephemeral — not stored in state."
  ephemeral   = true
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
  default     = null
  description = "Azure Monitor instrumentation key used by Dapr to export Service to Service communication telemetry. Ephemeral — not stored in state."
  ephemeral   = true
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
  type        = string
  default     = null
  description = "DEPRECATED: Use `dapr_ai_connection_string` (ephemeral) + `dapr_ai_connection_string_version` instead. Will be removed in a future major release."
  ephemeral   = true
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

variable "ignore_body_changes" {
  type = object({
    app_managed_environments       = optional(list(string), [])
    authorization_locks            = optional(list(string), [])
    authorization_role_assignments = optional(list(string), [])
    insights_diagnostic_settings   = optional(list(string), [])

    app_managed_environments_certificates = optional(object({
      app_managed_environments_certificates = optional(list(string), [])
    }), {})
    app_managed_environments_dapr_components = optional(object({
      app_managed_environments_dapr_components = optional(list(string), [])
    }), {})
    app_managed_environments_dapr_subscriptions = optional(object({
      app_managed_environments_dapr_subscriptions = optional(list(string), [])
    }), {})
    app_managed_environments_dot_net_components = optional(object({
      app_managed_environments_dot_net_components = optional(list(string), [])
    }), {})
    app_managed_environments_http_route_configs = optional(object({
      app_managed_environments_http_route_configs = optional(list(string), [])
    }), {})
    app_managed_environments_java_components = optional(object({
      app_managed_environments_java_components = optional(list(string), [])
    }), {})
    app_managed_environments_maintenance_configurations = optional(object({
      app_managed_environments_maintenance_configurations = optional(list(string), [])
    }), {})
    app_managed_environments_managed_certificates = optional(object({
      app_managed_environments_managed_certificates = optional(list(string), [])
    }), {})
    app_managed_environments_storages = optional(object({
      app_managed_environments_storages = optional(list(string), [])
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
Paths in each resource's `body` whose changes the AzAPI provider ignores. Prefer Terraform's `lifecycle.ignore_changes` when the paths are static; use this variable when the paths must be derived from variables or other non-static values.

Paths use dot notation, for example `properties.sku.name`. Individual list items cannot be targeted — ignore the whole list property instead. Configuration changes at an ignored path are **not** sent to Azure until that path is removed from the list.

Supplying a non-empty value requires Terraform 1.11 or later, because `ignore_body_changes` is a write-only argument. Changes take effect only after an apply, because the value is held in provider-private state.

- `app_managed_environments` - Ignored body paths for the Container Apps Managed Environment.
- `authorization_locks` - Ignored body paths for the management lock.
- `authorization_role_assignments` - Ignored body paths for the role assignments.
- `insights_diagnostic_settings` - Ignored body paths for the diagnostic settings.
- `app_managed_environments_certificates` - Override slot for the `certificates` submodule. Supply only the keys you want to override.
  - `app_managed_environments_certificates` - Ignored body paths for the certificates.
- `app_managed_environments_dapr_components` - Override slot for the `dapr_components` submodule.
  - `app_managed_environments_dapr_components` - Ignored body paths for the Dapr components.
- `app_managed_environments_dapr_subscriptions` - Override slot for the `dapr_subscriptions` submodule.
  - `app_managed_environments_dapr_subscriptions` - Ignored body paths for the Dapr subscriptions.
- `app_managed_environments_dot_net_components` - Override slot for the `dot_net_components` submodule.
  - `app_managed_environments_dot_net_components` - Ignored body paths for the .NET components.
- `app_managed_environments_http_route_configs` - Override slot for the `http_route_configs` submodule.
  - `app_managed_environments_http_route_configs` - Ignored body paths for the HTTP route configurations.
- `app_managed_environments_java_components` - Override slot for the `java_components` submodule.
  - `app_managed_environments_java_components` - Ignored body paths for the Java components.
- `app_managed_environments_maintenance_configurations` - Override slot for the `maintenance_configurations` submodule.
  - `app_managed_environments_maintenance_configurations` - Ignored body paths for the maintenance configurations.
- `app_managed_environments_managed_certificates` - Override slot for the `managed_certificates` submodule.
  - `app_managed_environments_managed_certificates` - Ignored body paths for the managed certificates.
- `app_managed_environments_storages` - Override slot for the `storages` submodule.
  - `app_managed_environments_storages` - Ignored body paths for the storages.
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
  default     = null
  description = "DataDog API key for `open_telemetry_configuration.destinations_configuration.data_dog_configuration`. Ephemeral — not stored in state. Use `key_version` to track changes."
  ephemeral   = true
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
    kind  = string
    name  = optional(string, null)
    notes = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
- `notes` - (Optional) Notes about the lock. This value maps to `Microsoft.Authorization/locks.properties.notes`. If not specified, a note describing the lock `kind` is used.

A `ReadOnly` lock also blocks changes to the environment's child resources, such as Dapr components and storages, and to its role assignments and diagnostic settings.
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
  type        = string
  default     = null
  description = "DEPRECATED: Use `shared_key` (ephemeral) + `shared_key_version` instead. Will be removed in a future major release."
  ephemeral   = true
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
  description = "The resource ID of the resource group in which to create the Container Apps Managed Environment, for example `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg`. When provided, takes precedence over `resource_group_name`. Changing this forces a new resource to be created."

  validation {
    condition     = var.parent_id == null || can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "`parent_id` must be a valid Azure resource group resource ID, or null."
  }
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

variable "resource_types" {
  type = object({
    app_managed_environments       = optional(string, "Microsoft.App/managedEnvironments@2025-10-02-preview")
    authorization_locks            = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    authorization_role_assignments = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
    insights_diagnostic_settings   = optional(string, "Microsoft.Insights/diagnosticSettings@2021-05-01-preview")

    app_managed_environments_certificates = optional(object({
      app_managed_environments_certificates = optional(string)
    }), {})
    app_managed_environments_dapr_components = optional(object({
      app_managed_environments_dapr_components = optional(string)
    }), {})
    app_managed_environments_dapr_subscriptions = optional(object({
      app_managed_environments_dapr_subscriptions = optional(string)
    }), {})
    app_managed_environments_dot_net_components = optional(object({
      app_managed_environments_dot_net_components = optional(string)
    }), {})
    app_managed_environments_http_route_configs = optional(object({
      app_managed_environments_http_route_configs = optional(string)
    }), {})
    app_managed_environments_java_components = optional(object({
      app_managed_environments_java_components = optional(string)
    }), {})
    app_managed_environments_maintenance_configurations = optional(object({
      app_managed_environments_maintenance_configurations = optional(string)
    }), {})
    app_managed_environments_managed_certificates = optional(object({
      app_managed_environments_managed_certificates = optional(string)
    }), {})
    app_managed_environments_storages = optional(object({
      app_managed_environments_storages = optional(string)
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
Override the AzAPI `<provider>/<resource>@<api-version>` strings used by this module and its submodules. Each key defaults to a tested value; supply only the keys you want to override. Useful when targeting a sovereign cloud with older API versions, or when opting into a newer preview API.

- `app_managed_environments` - The Container Apps Managed Environment.
- `authorization_locks` - The management lock.
- `authorization_role_assignments` - The role assignments.
- `insights_diagnostic_settings` - The diagnostic settings. The default is a preview version because the stable version does not support log category groups.
- `app_managed_environments_certificates` - Override slot for the `certificates` submodule. Defaults live in the submodule; supply only the keys you want to override.
  - `app_managed_environments_certificates` - The certificate resource managed by the `certificates` submodule.
- `app_managed_environments_dapr_components` - Override slot for the `dapr_components` submodule. Defaults live in the submodule.
  - `app_managed_environments_dapr_components` - The Dapr component resource managed by the `dapr_components` submodule.
- `app_managed_environments_dapr_subscriptions` - Override slot for the `dapr_subscriptions` submodule. Defaults live in the submodule.
  - `app_managed_environments_dapr_subscriptions` - The Dapr subscription resource managed by the `dapr_subscriptions` submodule.
- `app_managed_environments_dot_net_components` - Override slot for the `dot_net_components` submodule. Defaults live in the submodule.
  - `app_managed_environments_dot_net_components` - The .NET component resource managed by the `dot_net_components` submodule.
- `app_managed_environments_http_route_configs` - Override slot for the `http_route_configs` submodule. Defaults live in the submodule.
  - `app_managed_environments_http_route_configs` - The HTTP route configuration resource managed by the `http_route_configs` submodule.
- `app_managed_environments_java_components` - Override slot for the `java_components` submodule. Defaults live in the submodule.
  - `app_managed_environments_java_components` - The Java component resource managed by the `java_components` submodule.
- `app_managed_environments_maintenance_configurations` - Override slot for the `maintenance_configurations` submodule. Defaults live in the submodule.
  - `app_managed_environments_maintenance_configurations` - The maintenance configuration resource managed by the `maintenance_configurations` submodule.
- `app_managed_environments_managed_certificates` - Override slot for the `managed_certificates` submodule. Defaults live in the submodule.
  - `app_managed_environments_managed_certificates` - The managed certificate resource managed by the `managed_certificates` submodule.
- `app_managed_environments_storages` - Override slot for the `storages` submodule. Defaults live in the submodule.
  - `app_managed_environments_storages` - The storage resource managed by the `storages` submodule.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ContainerAppEnvironmentDisabled"])
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = {}
  description = <<DESCRIPTION
Retry configuration applied to every `azapi` resource managed by the module (root resource and all submodules). By default the module retries `ContainerAppEnvironmentDisabled`, which the control plane returns until an environment that has scaled to zero finishes waking. Consumers **MAY** override any field.

- `error_message_regex`  - (Optional) A list of regex patterns matching error messages that trigger a retry. Defaults to `["ContainerAppEnvironmentDisabled"]`.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.

See <https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource#retry> for full semantics.
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
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
A map of role assignments to create on the Container Apps Managed Environment. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the role assignment. If not set, a random UUID will be generated. Changing this forces the creation of a new resource. Role assignments created by earlier versions of this module keep their existing name.
- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal. A name is matched, ignoring case, against the role definitions that can be assigned in the resource group. For a custom role that can only be assigned on this Container Apps Managed Environment, use its ID.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true and `principal_type` is not set, `principal_type` is set to `ServicePrincipal`, which skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.role_assignments :
      v.delegated_managed_identity_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", v.delegated_managed_identity_resource_id))
    ])
    error_message = "Each `role_assignments[*].delegated_managed_identity_resource_id` must be a valid user-assigned managed identity resource ID, or null."
  }
}

variable "shared_key" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Log analytics primary shared key. Ephemeral — not stored in state.

The preferred mechanism is to specify `log_analytics_workspace.resource_id`, in which case this can be left as `null`.

DESCRIPTION
  ephemeral   = true
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
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default per-operation timeouts applied to every `azapi` resource managed by the module (root resource and all submodules). Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read`   - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
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
        "Flex",
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
    error_message = "Invalid value for workload_profile_type. Valid options are 'Consumption', 'Flex', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32', 'DC4', 'DC8', 'DC16', 'DC32', 'DC48', 'DC64', 'DC96', 'NC24-A100', 'NC48-A100', 'NC96-A100', 'Consumption-GPU-NC24-A100', and 'Consumption-GPU-NC8as-T4'."
  }
  validation {
    condition = var.workload_profile == null ? true : alltrue([
      for wp in var.workload_profile :
      wp.workload_profile_type != "Flex" ||
      wp.name == "Flex"
    ])

    error_message = "When workload_profile_type is 'Flex', workload_profile name must be 'Flex'."
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
- `workload_profile_type` - (Required) Workload profile type for the workloads to run on. Current documented values are `Consumption`, `Flex`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16`, `E32`, `DC4`, `DC8`, `DC16`, `DC32`, `DC48`, `DC64`, `DC96`, `NC24-A100`, `NC48-A100`, `NC96-A100`, `Consumption-GPU-NC24-A100`, and `Consumption-GPU-NC8as-T4`.
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
        "Flex",
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
    error_message = "Invalid value for workload_profile_type. Valid options are 'Consumption', 'Flex', 'D4', 'D8', 'D16', 'D32', 'E4', 'E8', 'E16', 'E32', 'DC4', 'DC8', 'DC16', 'DC32', 'DC48', 'DC64', 'DC96', 'NC24-A100', 'NC48-A100', 'NC96-A100', 'Consumption-GPU-NC24-A100', and 'Consumption-GPU-NC8as-T4'."
  }
  validation {
    condition = var.workload_profiles == null ? true : alltrue([
      for wp in var.workload_profiles :
      wp.workload_profile_type != "Flex" ||
      wp.name == "Flex"
    ])

    error_message = "When workload_profile_type is 'Flex', workload_profiles name must be 'Flex'."
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
