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

# Create the vnet to use with vnet integration
resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/23"]
      }
      subnets = [
        {
          name = module.naming.subnet.name_unique
          properties = {
            addressPrefix = "192.168.0.0/23"
            delegations = [
              {
                name = "Microsoft.App.environments"
                properties = {
                  serviceName = "Microsoft.App/environments"
                }
              }
            ]
          }
        }
      ]
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

resource "azapi_resource" "user_assigned_identity" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
}

module "managedenvironment" {
  source = "../../"

  location            = azapi_resource.resource_group.location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azapi_resource.resource_group.name
  dapr_components = {
    "my-dapr-component" = {
      component_type          = "state.azure.blobstorage"
      dapr_components_version = "v1"
      ignore_errors           = true
      location                = azapi_resource.resource_group.location
      name                    = "my-dapr-component"
    }
  }
  enable_telemetry              = var.enable_telemetry
  infrastructure_resource_group = "rg-managed-${module.naming.container_app_environment.name_unique}"
  log_analytics_workspace       = { resource_id = azapi_resource.log_analytics_workspace.id }
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azapi_resource.user_assigned_identity.id]
  }
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
  vnet_configuration = {
    infrastructure_subnet_id = "${azapi_resource.virtual_network.id}/subnets/${module.naming.subnet.name_unique}"
    internal                 = true
  }
  workload_profiles = [
    {
      name                  = "Consumption"
      workload_profile_type = "Consumption"
    }
  ]
  zone_redundant = true
}
