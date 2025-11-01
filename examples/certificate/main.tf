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

# Example: Create a Key Vault for certificate storage
resource "azurerm_key_vault" "this" {
  location                   = azurerm_resource_group.this.location
  name                       = module.naming.key_vault.name_unique
  resource_group_name        = azurerm_resource_group.this.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

data "azurerm_client_config" "current" {}

# Example managed identity for Key Vault access
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.user_assigned_identity.name_unique}-env"
  resource_group_name = azurerm_resource_group.this.name
}

# Grant the managed identity permission to read certificates from Key Vault
resource "azurerm_role_assignment" "kv_secrets_user" {
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.this.id
}

module "managedenvironment" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.container_app_environment.name_unique
  resource_group_name = azurerm_resource_group.this.name

  log_analytics_workspace = {
    resource_id = azurerm_log_analytics_workspace.this.id
  }

  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundancy_enabled = false

  # Configure managed identity for Key Vault access
  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }

  # Example 1: Direct certificate upload
  # Uncomment and provide valid certificate file and password
  # certificates = {
  #   "direct-upload-cert" = {
  #     certificate_value    = filebase64("./path/to/certificate.pfx")
  #     certificate_password = "YourCertificatePassword"
  #   }
  # }

  # Example 2: Key Vault reference
  # Uncomment and provide valid Key Vault secret ID
  # certificates = {
  #   "keyvault-ref-cert" = {
  #     key_vault_secret_id = "${azurerm_key_vault.this.vault_uri}secrets/my-certificate/latest"
  #   }
  # }

  # Example 3: Mixed approach - both direct and Key Vault
  # certificates = {
  #   "direct-cert" = {
  #     certificate_value    = filebase64("./direct-cert.pfx")
  #     certificate_password = "Password123"
  #   }
  #   "keyvault-cert" = {
  #     key_vault_secret_id = "${azurerm_key_vault.this.vault_uri}secrets/kv-cert/latest"
  #   }
  # }

  # Enable peer traffic encryption (requires certificates)
  # peer_traffic_encryption_enabled = true

  # Configure custom domain with Key Vault properties
  # custom_domain_certificate_key_vault_id       = azurerm_key_vault.this.id
  # custom_domain_certificate_identity_client_id = azurerm_user_assigned_identity.this.client_id
}
