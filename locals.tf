locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  location                           = var.location != null ? var.location : data.azurerm_resource_group.rg.location
}
