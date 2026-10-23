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

# Container Apps mounts Azure Files with the account key, so shared key access must stay enabled.
resource "azapi_resource" "storage_account" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Storage/storageAccounts@2024-01-01"
  body = {
    kind = "StorageV2"
    properties = {
      allowBlobPublicAccess    = false
      allowSharedKeyAccess     = true
      minimumTlsVersion        = "TLS1_2"
      supportsHttpsTrafficOnly = true
    }
    sku = {
      name = "Standard_ZRS"
    }
  }
}

resource "azapi_resource" "file_share" {
  name      = "sharename"
  parent_id = "${azapi_resource.storage_account.id}/fileServices/default"
  type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2024-01-01"
  body = {
    properties = {
      shareQuota = 5
    }
  }
}

data "azapi_resource_action" "storage_account_keys" {
  action                           = "listKeys"
  method                           = "POST"
  resource_id                      = azapi_resource.storage_account.id
  type                             = "Microsoft.Storage/storageAccounts@2024-01-01"
  response_export_values           = []
  sensitive_response_export_values = ["keys"]
}

module "managedenvironment" {
  source = "../../"

  location                = azapi_resource.resource_group.location
  name                    = module.naming.container_app_environment.name_unique
  resource_group_name     = azapi_resource.resource_group.name
  enable_telemetry        = var.enable_telemetry
  log_analytics_workspace = { resource_id = azapi_resource.log_analytics_workspace.id }
  storages = {
    "mycontainerappstorage" = {
      azure_file = {
        access_mode  = "ReadOnly"
        account_name = azapi_resource.storage_account.name
        share_name   = azapi_resource.file_share.name
      }
      account_key         = data.azapi_resource_action.storage_account_keys.sensitive_output.keys[0].value
      account_key_version = 1
      location            = azapi_resource.resource_group.location
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
