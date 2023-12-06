locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  infrastructure_resource_group_name = coalesce(var.infrastructure_resource_group_name, replace(var.resource_group_name, "rg-", "rg-managed-"))
}
