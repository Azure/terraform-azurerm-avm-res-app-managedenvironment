locals {
  dapr_component_metadata_secrets_output = {
    for dk, dv in azapi_resource.dapr_components :
    dk => dv.body.properties.metadata != null ? [
      for item in dv.body.properties.metadata : {
        value = item.value
      }
    ] : null
  }
  dapr_component_outputs = {
    for dk, dv in azapi_resource.dapr_components :
    dk => {
      id                     = dv.id
      component_type         = dv.body.properties.componentType
      ignore_errors          = dv.body.properties.ignoreErrors
      init_timeout           = dv.body.properties.initTimeout
      secret_store_component = dv.body.properties.secretStoreComponent
      scopes                 = dv.body.properties.scopes
      version                = dv.body.properties.version
      metadata = dv.body.properties.metadata != null ? [
        for item in dv.body.properties.metadata : {
          name        = item.name
          secret_name = item.secretRef
        }
      ] : null
      secret = dv.body.properties.secrets != null ? [
        for item in dv.body.properties.secrets : {
          name                = item.name
          identity            = item.identity
          key_vault_secret_id = item.keyVaultUrl
        }
      ] : null
    }
  }
  dapr_component_secrets_output = {
    for dk, dv in azapi_resource.dapr_components :
    dk => dv.body.properties.secrets != null ? [
      for item in dv.body.properties.secrets : {
        value = item.value
      }
    ] : null
  }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  # access keys are kept separate because they need to be marked as sensitive
  storage_access_key_outputs = {
    for sk, sv in azapi_resource.storages :
    sk => sv.body.properties.azureFile.accountKey
  }
  storages_outputs = {
    for sk, sv in azapi_resource.storages :
    sk => {
      id           = sv.id
      access_mode  = sv.body.properties.azureFile.accessMode
      account_name = sv.body.properties.azureFile.accountName
      share_name   = sv.body.properties.azureFile.shareName
    }
  }
  # this is used to mimic the behaviour of the azurerm provider
  workload_profile_consumption_enabled = contains([
    for wp in var.workload_profile :
    wp.name == "Consumption" && wp.workload_profile_type == "Consumption"
  ], true)
}
