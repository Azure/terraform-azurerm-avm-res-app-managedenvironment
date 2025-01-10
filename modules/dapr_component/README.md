<!-- BEGIN_TF_DOCS -->
# Azure Container Apps Managed Environment Dapr Components Module

This module is used to create Dapr Components for a Container Apps Environment.

## Usage

```terraform
module "avm-res-app-managedenvironment-daprcomponent" {
  source = "Azure/avm-res-app-managedenvironment/azurerm//modules/dapr_component"

  managed_environment = {
    resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.App/managedEnvironments/myEnv"
  }

  component_type = "state.azure.blobstorage"
  version        = "v1"
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.13, < 3)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (>= 1.13, < 3)

## Resources

The following resources are used by this module:

- [azapi_resource.this](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_component_type"></a> [component\_type](#input\_component\_type)

Description: The type of the Dapr component.

Type: `string`

### <a name="input_managed_environment"></a> [managed\_environment](#input\_managed\_environment)

Description: The Dapr component resource.

Type:

```hcl
object({
    resource_id = string
  })
```

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Dapr component.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dapr_component_version"></a> [dapr\_component\_version](#input\_dapr\_component\_version)

Description: The version of the Dapr component.

Type: `string`

Default: `null`

### <a name="input_ignore_errors"></a> [ignore\_errors](#input\_ignore\_errors)

Description: Whether to ignore errors for the Dapr component.

Type: `bool`

Default: `false`

### <a name="input_init_timeout"></a> [init\_timeout](#input\_init\_timeout)

Description: The initialization timeout for the Dapr component.

Type: `string`

Default: `null`

### <a name="input_metadata"></a> [metadata](#input\_metadata)

Description: The metadata for the Dapr component.

Type:

```hcl
list(object({
    name        = string
    secret_name = string
    value       = string
  }))
```

Default: `null`

### <a name="input_scopes"></a> [scopes](#input\_scopes)

Description: The scopes for the Dapr component.

Type: `list(string)`

Default: `[]`

### <a name="input_secret"></a> [secret](#input\_secret)

Description: The secrets for the Dapr component.

Type:

```hcl
set(object({
    # identity            = string
    # key_vault_secret_id = string
    name  = string
    value = string
  }))
```

Default: `null`

### <a name="input_secret_store_component"></a> [secret\_store\_component](#input\_secret\_store\_component)

Description: The secret store component for the Dapr component.

Type: `string`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description:  - `create` - (Defaults to 30 minutes) Used when creating the Dapr component.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Dapr component.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Dapr component.
 - `update` - (Defaults to 30 minutes) Used when updating the Dapr component.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource ID of the dapr component.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->