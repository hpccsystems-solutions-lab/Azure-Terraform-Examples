module "acr" {
  source  = "git@github.com:LexisNexis-RBA/terraform-azurerm-container-registry.git"

  location            = module.metadata.location
  resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name
  names               = module.metadata.names
  tags                = module.metadata.tags

  sku = "Premium"

  admin_enabled    = true

  access_list = {
    "my_ip" = "${chomp(data.http.my_ip.body)}/32"
  }

  /*service_endpoints = {
    "iaas-outbound" = module.virtual_network.subnet["iaas-outbound"].id
  }*/
}