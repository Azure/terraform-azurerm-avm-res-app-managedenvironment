terraform {
  required_version = ">= 1.12, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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

# Example: Create a Key Vault for certificate storage
# Purge protection stays disabled by omitting enablePurgeProtection, because the API does not accept false.
resource "azapi_resource" "key_vault" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.key_vault.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.KeyVault/vaults@2023-07-01"
  body = {
    properties = {
      accessPolicies            = []
      enableRbacAuthorization   = true
      enableSoftDelete          = true
      softDeleteRetentionInDays = 7
      sku = {
        family = "A"
        name   = "standard"
      }
      tenantId = data.azapi_client_config.current.tenant_id
    }
  }
}

data "azapi_client_config" "current" {}

# Example managed identity for Key Vault access
resource "azapi_resource" "user_assigned_identity" {
  location               = azapi_resource.resource_group.location
  name                   = "${module.naming.user_assigned_identity.name_unique}-env"
  parent_id              = azapi_resource.resource_group.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  response_export_values = ["properties.principalId", "properties.clientId"]
}

resource "random_uuid" "role_assignment_kv_secrets_user" {}

# Grant the managed identity permission to read certificates from Key Vault
# (4633458b-17de-408a-b874-0445c86b69e6 is the built-in Key Vault Secrets User role).
resource "azapi_resource" "role_assignment_kv_secrets_user" {
  name      = random_uuid.role_assignment_kv_secrets_user.result
  parent_id = azapi_resource.key_vault.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = azapi_resource.user_assigned_identity.output.properties.principalId
      principalType    = "ServicePrincipal"
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6"
    }
  }
}

module "managedenvironment" {
  source = "../../"

  location            = azapi_resource.resource_group.location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azapi_resource.resource_group.name
  enable_telemetry    = var.enable_telemetry
  log_analytics_workspace = {
    resource_id = azapi_resource.log_analytics_workspace.id
  }
  # Configure managed identity for Key Vault access
  managed_identities = {
    user_assigned_resource_ids = [azapi_resource.user_assigned_identity.id]
  }
  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundant = false
}
