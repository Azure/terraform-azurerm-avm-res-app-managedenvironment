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

  location                = azurerm_resource_group.this.location
  name                    = module.naming.container_app_environment.name_unique
  resource_group_name     = azurerm_resource_group.this.name
  log_analytics_workspace = { resource_id = azurerm_log_analytics_workspace.this.id }
  storages = {
    "mycontainerappstorage" = {
      azure_file = {
        access_mode  = "ReadOnly"
        account_name = azurerm_storage_account.this.name
        share_name   = azurerm_storage_share.this.name
      }
      account_key         = azurerm_storage_account.this.primary_access_key
      account_key_version = 1
      location            = azurerm_resource_group.this.location
      name                = "mycontainerappstorage"
    }
  }
  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundant = false
}

moved {
  from = module.managedenvironment.azapi_resource.storages["mycontainerappstorage"]
  to   = module.managedenvironment.module.storages["mycontainerappstorage"].azapi_resource.this
}
