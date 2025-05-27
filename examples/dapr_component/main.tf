terraform {
  required_version = ">= 1.3.0"
  required_providers {
    # ignore this because we want to force the use of AzAPI v1 within the module without having it used in this example.
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13, < 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
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

module "managedenvironment" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azurerm_resource_group.this.name
  dapr_components = {
    "my-dapr-component" = {
      component_type = "state.azure.blobstorage"
      version        = "v1"
    }
  }
  log_analytics_workspace_customer_id        = azurerm_log_analytics_workspace.this.workspace_id
  log_analytics_workspace_primary_shared_key = azurerm_log_analytics_workspace.this.primary_shared_key
  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundancy_enabled = false
}

moved {
  from = module.managedenvironment.azapi_resource.dapr_components["my-dapr-component"]
  to   = module.managedenvironment.module.dapr_component["my-dapr-component"].azapi_resource.this
}
