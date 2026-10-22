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

module "managedenvironment" {
  source = "../../"

  location            = azapi_resource.resource_group.location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azapi_resource.resource_group.name
  enable_telemetry    = var.enable_telemetry
  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundant = false
}
