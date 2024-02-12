locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  workload_profile_outputs = jsondecode(data.azapi_resource.this_environment.output).properties.workloadProfiles != null ? [
    for wp in jsondecode(data.azapi_resource.this_environment.output).properties.workloadProfiles : merge(
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

  storages_outputs = {
    for sk, sv in azapi_resource.storages :
    sk => {
      id           = sv.id
      access_mode  = jsondecode(sv.body).properties.azureFile.accessMode
      access_key   = jsondecode(sv.body).properties.azureFile.accountKey
      account_name = jsondecode(sv.body).properties.azureFile.accountName
      share_name   = jsondecode(sv.body).properties.azureFile.shareName
    }
  }

  dapr_component_outputs = {
    for dk, dv in azapi_resource.dapr_components :
    dk => {
      id                     = dv.id
      component_type         = jsondecode(dv.body).properties.componentType
      ignore_errors          = jsondecode(dv.body).properties.ignoreErrors
      init_timeout           = jsondecode(dv.body).properties.initTimeout
      secret_store_component = jsondecode(dv.body).properties.secretStoreComponent
      scopes                 = jsondecode(dv.body).properties.scopes
      version                = jsondecode(dv.body).properties.version
      metadata = jsondecode(dv.body).properties.metadata != null ? [
        for item in jsondecode(dv.body).properties.metadata : {
          name        = item.name
          secret_name = item.secretRef
          value       = item.value
        }
      ] : null
      secret = jsondecode(dv.body).properties.secrets != null ? [
        for item in jsondecode(dv.body).properties.secrets : {
          name                = item.name
          value               = item.value
          identity            = item.identity
          key_vault_secret_id = item.keyVaultUrl
        }
      ] : null
    }
  }
}
