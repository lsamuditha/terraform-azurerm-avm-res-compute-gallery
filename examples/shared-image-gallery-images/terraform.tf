terraform {
  required_version = ">= 1.7"
  required_providers {
    # Ensure all required providers are listed here and the version property includes a constraint on the maximum major version.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.108"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
