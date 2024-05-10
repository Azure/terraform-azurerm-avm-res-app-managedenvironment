locals {
  dapr_component_outputs = {
    for dk, dv in azapi_resource.dapr_components :
    dk => {
      id                     = dv.id
      component_type         = dv.output.properties.componentType
      ignore_errors          = dv.output.properties.ignoreErrors
      init_timeout           = dv.output.properties.initTimeout
      secret_store_component = dv.output.properties.secretStoreComponent
      scopes                 = dv.output.properties.scopes
      version                = dv.output.properties.version
      metadata = dv.output.properties.metadata != null ? [
        for item in dv.output.properties.metadata : {
          name        = item.name
          secret_name = item.secretRef
          value       = item.value
        }
      ] : null
      secret = dv.output.properties.secrets != null ? [
        for item in dv.output.properties.secrets : {
          name                = item.name
          value               = item.value
          identity            = item.identity
          key_vault_secret_id = item.keyVaultUrl
        }
      ] : null
    }
  }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  storages_outputs = {
    for sk, sv in azapi_resource.storages :
    sk => {
      id           = sv.id
      access_mode  = sv.output.properties.azureFile.accessMode
      access_key   = sv.output.properties.azureFile.accountKey
      account_name = sv.output.properties.azureFile.accountName
      share_name   = sv.output.properties.azureFile.shareName
    }
  }
  workload_profile_outputs = azapi_resource.this_environment.output.properties.workloadProfiles != null ? [
    for wp in azapi_resource.this_environment.output.properties.workloadProfiles : merge(
      {
        name                  = wp.name
        workload_profile_type = wp.workloadProfileType
      },
      # minimumCount and maximumCount are not applicable if the workloadProfileType is "Consumption"
      wp.workloadProfileType != "Consumption" ? {
        minimum_count = wp.minimumCount
        maximum_count = wp.maximumCount
      } : {}
    )
  ] : null
  # these workload_profile_* locals are used to mimic the behaviour of the azurerm provider
  workload_profiles_consumption_enabled = contains(
    var.workload_profile,
    {
      name                = "Consumption"
      workloadProfileType = "Consumption"
    }
  )
  workload_profiles = setsubtract(var.workload_profile, [{
    name                = "Consumption"
    workloadProfileType = "Consumption"
  }])
}
