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
  workload_profiles = toset(concat(
    [
      for wp in var.workload_profile : {
        name                = wp.name
        workloadProfileType = wp.workload_profile_type
        minimumCount        = wp.minimum_count
        maximumCount        = wp.maximum_count
      }
    ],
    [
      {
        name                = "Consumption"
        workloadProfileType = "Consumption"
        minimumCount        = null
        maximumCount        = null
      }
    ],
  ))
}

locals {
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
}
