terraform {
  required_version = ">= 1.12, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/avm-utl-naming/azure"
  version = "0.2.0"
}

# This is required for resource modules
resource "azapi_resource" "resource_group" {
  location = "australiaeast"
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.log_analytics_workspace.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

resource "azapi_resource" "application_insights" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.application_insights.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = "web"
    properties = {
      Application_Type    = "web"
      WorkspaceResourceId = azapi_resource.log_analytics_workspace.id
    }
  }
  response_export_values = ["properties.ConnectionString", "properties.InstrumentationKey"]
}

module "managedenvironment" {
  source = "../../"

  location                          = azapi_resource.resource_group.location
  name                              = module.naming.container_app_environment.name_unique
  resource_group_name               = azapi_resource.resource_group.name
  dapr_ai_connection_string         = azapi_resource.application_insights.output.properties.ConnectionString
  dapr_ai_connection_string_version = 1
  dapr_components = {
    "my-dapr-component" = {
      component_type          = "state.azure.blobstorage"
      dapr_components_version = "v1"
      name                    = "my-dapr-component"
    }
  }
  enable_telemetry        = var.enable_telemetry
  log_analytics_workspace = { resource_id = azapi_resource.log_analytics_workspace.id }
  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundant = false
}

moved {
  from = module.managedenvironment.azapi_resource.dapr_components["my-dapr-component"]
  to   = module.managedenvironment.module.dapr_components["my-dapr-component"].azapi_resource.this
}
