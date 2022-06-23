terraform {
  backend "local" {}
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.9.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id =  var.tenant_id
  features {}
}
