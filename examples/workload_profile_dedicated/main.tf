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

# Create the vnet to use with vnet integration
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/23"]
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

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
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
  infrastructure_resource_group_name = "rg-managed-${module.naming.container_app_environment.name_unique}"
  infrastructure_subnet_id           = azurerm_subnet.this.id
  internal_load_balancer_enabled     = true
  log_analytics_workspace            = { resource_id = azurerm_log_analytics_workspace.this.id }
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }
  storages = {
    "mycontainerappstorage" = {
      account_name = azurerm_storage_account.this.name
      share_name   = azurerm_storage_share.this.name
      access_key   = azurerm_storage_account.this.primary_access_key
      access_mode  = "ReadOnly"
    }
  }
  workload_profile = [{
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }]
  zone_redundancy_enabled = true
}
