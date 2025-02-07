terraform {
  required_version = ">= 1.3.0"
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

resource "azurerm_storage_account" "this" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
}

resource "azurerm_storage_share" "this" {
  name                 = "sharename"
  quota                = 5
  storage_account_name = azurerm_storage_account.this.name
}

module "managedenvironment" {
  source = "../../"
  # source = "Azure/avm-res-app-managedenvironment/azurerm"

  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  log_analytics_workspace_customer_id        = azurerm_log_analytics_workspace.this.workspace_id
  log_analytics_workspace_primary_shared_key = azurerm_log_analytics_workspace.this.primary_shared_key

  storages = {
    "mycontainerappstorage" = {
      account_name = azurerm_storage_account.this.name
      share_name   = azurerm_storage_share.this.name
      access_key   = azurerm_storage_account.this.primary_access_key
      access_mode  = "ReadOnly"
    }
  }

  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundancy_enabled = false
}

moved {
  from = module.managedenvironment.azapi_resource.storages["mycontainerappstorage"]
  to   = module.managedenvironment.module.storage["mycontainerappstorage"].azapi_resource.this
}
