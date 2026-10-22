terraform {
  required_version = ">= 1.12, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

resource "azapi_resource" "resource_group" {
  location = "australiaeast"
  name     = "rg-avm-cae-int-${random_string.suffix.result}"
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
}

data "azapi_client_config" "current" {}

output "location" {
  description = "The location of the test resource group."
  value       = azapi_resource.resource_group.location
}

output "resource_group_id" {
  description = "The resource ID of the test resource group."
  value       = azapi_resource.resource_group.id
}

output "resource_group_name" {
  description = "The name of the test resource group."
  value       = azapi_resource.resource_group.name
}

output "subscription_id" {
  description = "The ID of the subscription the tests run in."
  value       = data.azapi_client_config.current.subscription_id
}
