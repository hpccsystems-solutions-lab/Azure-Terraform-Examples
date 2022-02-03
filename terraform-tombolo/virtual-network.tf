module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network"

  resource_group_name   = module.resource-group.name
  location              = module.resource-group.location
  names                 = module.metadata.names
  tags                  = module.metadata.tags

  address_space         = ["10.1.0.0/24"]// 10.1.0.0 - 10.1.0.255 (255 addresses total)
  
  enforce_subnet_names  = false
  
  subnets = {
    app-gateway = {
      cidrs = ["10.1.0.0/27"]
      create_network_security_group = false
    }

    app-ui = {
      cidrs = ["10.1.0.32/27"]
      enforce_private_link_endpoint_network_policies  = true
      enforce_private_link_service_network_policies   = true
      create_network_security_group = false
    }
    app-api = {
      cidrs = ["10.1.0.64/27"]
      delegations = {
        "delegation" = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }   
    }
    mysql-db = {
      cidrs = ["10.1.0.96/27"]
      enforce_private_link_endpoint_network_policies  = true
      enforce_private_link_service_network_policies   = true
    }      
  }      
}

resource "azurerm_network_security_group" "app-gateway-nsg" {
  name                = "app-gateway-nsg"
  location            = module.resource-group.location
  resource_group_name = module.resource-group.name  
}

resource "azurerm_network_security_rule" "lnrsvpnallowhttpaccess" {
  name                        = "LNRSVPNAllowHttp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "${chomp(data.http.my_ip.body)}"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource-group.name
  network_security_group_name = azurerm_network_security_group.app-gateway-nsg.name
}

resource "azurerm_network_security_rule" "allowgatewaymanager" {
  name                        = "AllowGatewayManagerAccess"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource-group.name
  network_security_group_name = azurerm_network_security_group.app-gateway-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "app-gateway-subnet-nsg" {
  subnet_id                 = module.virtual_network.subnet["app-gateway"].id
  network_security_group_id = azurerm_network_security_group.app-gateway-nsg.id
}