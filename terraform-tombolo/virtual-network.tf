resource "azurerm_virtual_network" "tombolo-dev-eastus2-vnet" {
  name                  = "tombolo-dev-eastus2-vnet"
  location              = azurerm_resource_group.app-tombolo-dev-eastus2.location
  tags                  = module.metadata.tags  
  resource_group_name   = azurerm_resource_group.app-tombolo-dev-eastus2.name
  address_space         = ["10.1.0.0/22"]
}

module "subnet" {
  for_each = var.subnets
  source  = "tfe.lnrisk.io/Infrastructure/virtual-network/azurerm//subnet"

  naming_rules = module.naming.yaml

  resource_group_name                             = azurerm_resource_group.app-tombolo-dev-eastus2.name
  location                                        = azurerm_resource_group.app-tombolo-dev-eastus2.location
  names                                           = module.metadata.names
  tags                                            = module.metadata.tags  

  virtual_network_name                            = azurerm_virtual_network.tombolo-dev-eastus2-vnet.name
  enforce_subnet_names                            = false
  allow_vnet_inbound                              = true
  allow_vnet_outbound                             = true
  cidrs                                           = each.value["cidr"]
  subnet_type                                     = each.value["type"]
  delegations                                     = each.value["delegations"]
  create_network_security_group                   = false
  enforce_private_link_endpoint_network_policies  = true
  enforce_private_link_service_network_policies   = true
}