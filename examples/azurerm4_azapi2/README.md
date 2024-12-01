<!-- BEGIN_TF_DOCS -->
# Example to test AzureRM v4 and AzAPI v2

This deploys the module with all the supported subcomponents using AzureRM v4 and AzAPI v2.

```hcl
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    # ignore this because we want to force the use of AzAPI v2 within the module without having it used in this example.
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "australiaeast"
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# Create the vnet to use with vnet integration
resource "azurerm_virtual_network" "this" {
  address_space       = ["192.168.0.0/23"]
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  address_prefixes     = ["192.168.0.0/23"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  delegation {
    name = "Microsoft.App.environments"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_storage_account" "this" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
}

resource "azurerm_storage_share" "this" {
  name               = "sharename"
  quota              = 5
  storage_account_id = azurerm_storage_account.this.id
}

module "managedenvironment" {
  source = "../../"
  # source = "Azure/avm-res-app-managedenvironment/azurerm"

  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  infrastructure_subnet_id = azurerm_subnet.this.id
  workload_profile = [{
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }]
  zone_redundancy_enabled            = true
  internal_load_balancer_enabled     = true
  infrastructure_resource_group_name = "rg-managed-${module.naming.container_app_environment.name_unique}"

  log_analytics_workspace_customer_id        = azurerm_log_analytics_workspace.this.workspace_id
  log_analytics_workspace_primary_shared_key = azurerm_log_analytics_workspace.this.primary_shared_key

  dapr_components = {
    "my-dapr-component" = {
      component_type = "state.azure.blobstorage"
      version        = "v1"
    }
  }

  storages = {
    "mycontainerappstorage" = {
      account_name = azurerm_storage_account.this.name
      share_name   = azurerm_storage_share.this.name
      access_key   = azurerm_storage_account.this.primary_access_key
      access_mode  = "ReadOnly"
    }
  }

}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) (resource)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_dapr_component_metadata_secrets"></a> [dapr\_component\_metadata\_secrets](#output\_dapr\_component\_metadata\_secrets)

Description: The metadata secrets output of the Dapr components.

### <a name="output_dapr_component_secrets"></a> [dapr\_component\_secrets](#output\_dapr\_component\_secrets)

Description: The secrets output of the Dapr components.

### <a name="output_dapr_components"></a> [dapr\_components](#output\_dapr\_components)

Description: A map of dapr components connected to this environment. The map key is the supplied input to var.storages. The map value is the azurerm-formatted version of the entire dapr\_components resource.

### <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain)

Description: The default domain of the Container Apps Managed Environment.

### <a name="output_docker_bridge_cidr"></a> [docker\_bridge\_cidr](#output\_docker\_bridge\_cidr)

Description: The Docker bridge CIDR of the Container Apps Managed Environment.

### <a name="output_id"></a> [id](#output\_id)

Description: The resource ID of the Container Apps Managed Environment.

### <a name="output_infrastructure_resource_group"></a> [infrastructure\_resource\_group](#output\_infrastructure\_resource\_group)

Description: The infrastructure resource group of the Container Apps Managed Environment.

### <a name="output_mtls_enabled"></a> [mtls\_enabled](#output\_mtls\_enabled)

Description: Indicates if mTLS is enabled for the Container Apps Managed Environment.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Container Apps Managed Environment.

### <a name="output_platform_reserved_cidr"></a> [platform\_reserved\_cidr](#output\_platform\_reserved\_cidr)

Description: The platform reserved CIDR of the Container Apps Managed Environment.

### <a name="output_platform_reserved_dns_ip_address"></a> [platform\_reserved\_dns\_ip\_address](#output\_platform\_reserved\_dns\_ip\_address)

Description: The platform reserved DNS IP address of the Container Apps Managed Environment.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource ID of the Container Apps Managed Environment.

### <a name="output_static_ip_address"></a> [static\_ip\_address](#output\_static\_ip\_address)

Description: The static IP address of the Container Apps Managed Environment.

### <a name="output_storages"></a> [storages](#output\_storages)

Description: The storage of the Container Apps Managed Environment.

### <a name="output_storages_access_keys"></a> [storages\_access\_keys](#output\_storages\_access\_keys)

Description: The storage access keys for storage resources attached to the Container Apps Managed Environment.

## Modules

The following Modules are called:

### <a name="module_managedenvironment"></a> [managedenvironment](#module\_managedenvironment)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->