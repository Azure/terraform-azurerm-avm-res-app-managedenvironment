terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.12.0, < 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0"
    }
  }
}
