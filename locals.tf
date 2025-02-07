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
  # workload profiles can be null, in this case a Consumption Only plan is created.
  workload_profiles = length(var.workload_profile) > 0 ? toset(concat(
    [
      for wp in var.workload_profile : {
        name                = wp.name
        workloadProfileType = wp.workload_profile_type
        minimumCount        = wp.minimum_count
        maximumCount        = wp.maximum_count
      }
      if wp.workload_profile_type != "Consumption"
    ],
    # if you specify a dedicated workload profile, then a consumption profile is also created automatically.
    # we add this block to avoid idempotency issues on subsequent runs.
    # the consumption profile is a special case that does not need a minimum or maximum count
    # there can be at most one consumption profile.
    [
      {
        name                = "Consumption"
        workloadProfileType = "Consumption"
        minimumCount        = null
        maximumCount        = null
      }
    ]
  )) : null
}
