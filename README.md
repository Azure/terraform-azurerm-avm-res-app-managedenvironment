<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID

Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to https://semver.org/

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (1.9.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (1.9.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.71.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0)

## Resources

The following resources are used by this module:

- [azapi_resource.this_environment](https://registry.terraform.io/providers/Azure/azapi/1.9.0/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: Name for the resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_custom_domain_certificate_password"></a> [custom\_domain\_certificate\_password](#input\_custom\_domain\_certificate\_password)

Description: Certificate password for custom domain.

Type: `string`

Default: `null`

### <a name="input_custom_domain_dns_suffix"></a> [custom\_domain\_dns\_suffix](#input\_custom\_domain\_dns\_suffix)

Description: DNS suffix for custom domain.

Type: `string`

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_instrumentation_key"></a> [instrumentation\_key](#input\_instrumentation\_key)

Description: Instrumentation key for Dapr AI.

Type: `string`

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply to the Container Registry. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

Default: `{}`

### <a name="input_log_analytics_workspace_customer_id"></a> [log\_analytics\_workspace\_customer\_id](#input\_log\_analytics\_workspace\_customer\_id)

Description: Customer ID for Log Analytics workspace.

Type: `string`

Default: `null`

### <a name="input_log_analytics_workspace_destination"></a> [log\_analytics\_workspace\_destination](#input\_log\_analytics\_workspace\_destination)

Description: Destination for Log Analytics (options: 'log-analytics', 'azuremonitor', 'none').

Type: `string`

Default: `"log-analytics"`

### <a name="input_log_analytics_workspace_primary_shared_key"></a> [log\_analytics\_workspace\_primary\_shared\_key](#input\_log\_analytics\_workspace\_primary\_shared\_key)

Description: Primary shared key for Log Analytics.

Type: `string`

Default: `null`

### <a name="input_peer_authentication_enabled"></a> [peer\_authentication\_enabled](#input\_peer\_authentication\_enabled)

Description: Enable peer authentication (Mutual TLS).

Type: `bool`

Default: `false`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the Container Registry. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Custom tags to apply to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_vnet_internal_only"></a> [vnet\_internal\_only](#input\_vnet\_internal\_only)

Description: Restrict access to internal resources within VNet.

Type: `bool`

Default: `false`

### <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id)

Description: ID of the VNet subnet.

Type: `string`

Default: `null`

### <a name="input_workload_profiles"></a> [workload\_profiles](#input\_workload\_profiles)

Description: This lists the workload profiles that will be configured for the Managed Environment.  
This is in addition to the default Consumpion Plan workload profile.

- `name` - the name of the workload profile.
- `workloadProfileType` - workload profile type, this determines the amount of compute and memory resource available to the container apps deployed in an environment.
- `minimiumCount` - the minimum number of instances that must be deployed.
- `maximiumCount` - the maximum number of instances that may be deployed.

Type:

```hcl
list(object({
    name                = string
    workloadProfileType = string
    minimumCount        = optional(number, 3)
    maximumCount        = optional(number, 5)
  }))
```

Default: `[]`

### <a name="input_workload_profiles_enabled"></a> [workload\_profiles\_enabled](#input\_workload\_profiles\_enabled)

Description: Whether to use workload profiles, this will create the default Consumption Plan, for dedicated plans use `workload_profiles`

Type: `bool`

Default: `false`

### <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled)

Description: Enable zone-redundancy for the resource, this feature requires supplying an available subnet via `vnet_subnet_id`.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The Container Apps Managed Environment resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->