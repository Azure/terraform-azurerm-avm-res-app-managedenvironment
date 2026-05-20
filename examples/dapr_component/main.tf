terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    # ignore this because we want to force the use of AzAPI v1 within the module without having it used in this example.
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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

resource "azurerm_application_insights" "this" {
  application_type    = "web"
  location            = azurerm_resource_group.this.location
  name                = module.naming.application_insights.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

module "managedenvironment" {
  source = "../../"

  location                          = azurerm_resource_group.this.location
  name                              = module.naming.container_app_environment.name_unique
  resource_group_name               = azurerm_resource_group.this.name
  dapr_ai_connection_string         = azurerm_application_insights.this.connection_string
  dapr_ai_connection_string_version = 1
  dapr_components = {
    "my-dapr-component" = {
      component_type          = "state.azure.blobstorage"
      dapr_components_version = "v1"
      name                    = "my-dapr-component"
    }
  }
  log_analytics_workspace = { resource_id = azurerm_log_analytics_workspace.this.id }
  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundant = false
}

moved {
  from = module.managedenvironment.azapi_resource.dapr_components["my-dapr-component"]
  to   = module.managedenvironment.module.dapr_components["my-dapr-component"].azapi_resource.this
}
