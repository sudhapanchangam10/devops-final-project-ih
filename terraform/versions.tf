# =====================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# =====================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Azure authentication uses the active Azure CLI session.
provider "azurerm" {
  features {}
}