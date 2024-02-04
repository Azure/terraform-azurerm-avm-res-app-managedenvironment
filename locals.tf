locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  workload_profile_outputs = {
    for workload_profile, wp in jsondecode(data.azapi_resource.this_environment.output).properties.workloadProfiles :
    workload_profile => {
      name                  = wp.name
      workload_profile_type = wp.workloadProfileType
      maximum_count         = wp.maximumCount
      minimum_count         = wp.minimumCount
    }
  }
}
