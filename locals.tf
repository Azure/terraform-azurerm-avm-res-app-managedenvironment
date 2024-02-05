locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  workload_profile_outputs = jsondecode(data.azapi_resource.this_environment.output).properties.workloadProfiles != null ? [
    for wp in jsondecode(data.azapi_resource.this_environment.output).properties.workloadProfiles : merge(
      {
        name                  = wp.name
        workload_profile_type = wp.workloadProfileType
      },
      // Only include minimumCount and maximumCount if workloadProfileType is not "Consumption"
      wp.workloadProfileType != "Consumption" ? {
        minimum_count = wp.minimumCount
        maximum_count = wp.maximumCount
      } : {}
    )
  ] : null
}


