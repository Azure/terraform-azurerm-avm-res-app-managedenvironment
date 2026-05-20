locals {
  resource_body = {
    name = var.name
    properties = {
      azureFile = var.azure_file == null ? null : {
        accessMode = var.azure_file.access_mode
        accountKeyVaultProperties = var.azure_file.account_key_vault_properties == null ? null : {
          identity    = var.azure_file.account_key_vault_properties.identity
          keyVaultUrl = var.azure_file.account_key_vault_properties.key_vault_url
        }
        accountName = var.azure_file.account_name
        shareName   = var.azure_file.share_name
      }
      nfsAzureFile = var.nfs_azure_file == null ? null : {
        accessMode = var.nfs_azure_file.access_mode
        server     = var.nfs_azure_file.server
        shareName  = var.nfs_azure_file.share_name
      }
    }
  }
}
