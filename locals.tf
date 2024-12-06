locals {
  dapr_component_resource_ids = {
    for dk, dv in module.dapr_component :
    dk => {
      id = dv.resource_id
    }
  }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  storage_resource_ids = {
    for sk, sv in module.storage :
    sk => {
      id = sv.resource_id
    }
  }
  # this is used to mimic the behaviour of the azurerm provider
  workload_profile_consumption_enabled = contains([
    for wp in var.workload_profile :
    wp.name == "Consumption" && wp.workload_profile_type == "Consumption"
  ], true)
}
