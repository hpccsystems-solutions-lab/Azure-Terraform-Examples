module "subscription" {
  source = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = var.subscription_id
}

module "naming" {
  source  = "tfe.lnrisk.io/Infrastructure/naming/azurerm"
  version = "1.0.90"
}

module "metadata"{
  source = "tfe.lnrisk.io/Infrastructure/metadata/azurerm"  
  version = "1.5.2"
  naming_rules = module.naming.yaml
  
  market              = var.names.market
  location            = var.names.location 
  environment         = var.names.environment 
  project             = var.names.project
  business_unit       = var.names.business_unit
  product_group       = var.names.product_group
  product_name        = var.names.product_name 
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = var.names.subscription_type
  resource_group_type = var.names.resource_group_type
}