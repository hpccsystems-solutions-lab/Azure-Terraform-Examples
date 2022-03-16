#acr is not currently used in this app. it uses scm deployment from github actions
/*module "acr" {
  source  = "git@github.com:LexisNexis-RBA/terraform-azurerm-container-registry.git"

  location            = module.metadata.location
  resource_group_name = module.resource-group.name
  names               = module.metadata.names
  tags                = module.metadata.tags

  sku = "Premium"

  admin_enabled       = true

  disable_unique_suffix = true
}*/