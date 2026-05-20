terraform {
  required_version = "~> 1.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.7"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
