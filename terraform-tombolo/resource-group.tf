module "resource-group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group"
  
  names    = module.metadata.names
  location = module.metadata.location
  tags     = module.metadata.tags
}
