/*variable "default_connection_info" {
  description = "This variable is defined in the Terraform Enterprise workspace"
}

provider "vault" { 
  alias   = "azure_credentials"
  address = var.default_connection_info.vault_address
  token   = var.default_connection_info.vault_token
  version = "= 2.18.0"
}

module "default_azure_credentials" {
  providers = { vault = vault.azure_credentials }
  source = "github.com/openrba/terraform-enterprise-azure-credentials.git?ref=v0.2.0"

  connection_info = var.default_connection_info
}

provider "azuread" {
  version = "=1.2.2"

  tenant_id       = module.default_azure_credentials.tenant_id
  client_id       = module.default_azure_credentials.client_id
  client_secret   = module.default_azure_credentials.client_secret
}*/

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93.1"
    }
  }  
}

provider "azurerm" {
  features {}
}