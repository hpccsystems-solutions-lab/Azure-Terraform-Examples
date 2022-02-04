/*
  The Virual Network to is used to encapsulate the resources within a resource group.
  1) Isolation
  2) Organization
  3) Rules based Ingress and Egress 
  4) Peering to connect to other VNets or On Prem Express Route
*/

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network"

  resource_group_name   = module.resource-group.name
  location              = module.resource-group.location
  names                 = module.metadata.names
  tags                  = module.metadata.tags

  address_space         = ["10.1.0.0/24"]// 10.1.0.0 - 10.1.0.255 (255 addresses total)
  
  enforce_subnet_names  = false
  
  /* 
     Organize the resources into subnets. 

     1) Subnets encapsulates a set of resources and reserves IPs for these resources 
     2) Subnets help enforce network security rules using network securty groups
     3) A dedicated Subnet with enough IPs is a requirement for PaaS VNet integration
     4) Expanding a Subnet IP space will require the creation of a new Subnet, copying the existing resources from the old subnet to the new one and deleting the old subnet

  */

  subnets = {

    //App Gateway Subnet
    app-gateway = {
      cidrs = ["10.1.0.0/27"]//10.1.0.0 - 10.1.0.31  (32 addresses. With 5 reserved for Azure)
      create_network_security_group = false
    }
    
    //UI Code Subnet. The SPA is only accesable via the VNet and App Gateway
    app-ui = {
      cidrs = ["10.1.0.32/27"]//10.1.0.32 - 10.1.0.63  (32 addresses. With 5 reserved for Azure)
      enforce_private_link_endpoint_network_policies  = true
      enforce_private_link_service_network_policies   = true
      create_network_security_group = false
    }

    //API Subnet with VNet integration for App Services PaaS 
    app-api = {
      cidrs = ["10.1.0.64/27"]//10.1.0.64 - 10.1.0.95 (32 addresses. With 5 reserved for Azure)
      delegations = {
        "delegation" = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }   
    }

    //Subnet reserved for Private Endpoints
    mysql-db = {
      cidrs = ["10.1.0.96/27"]//10.1.0.96 - 10.1.0.127 (32 addresses. With 5 reserved for Azure)
      enforce_private_link_endpoint_network_policies  = true
      enforce_private_link_service_network_policies   = true
    }      
  }      
}

/* Network Security Group associated with the App Gateway subnet */

resource "azurerm_network_security_group" "app-gateway-nsg" {
  name                = "app-gateway-nsg"
  location            = module.resource-group.location
  resource_group_name = module.resource-group.name  
}

/* Security rule for app-gateway-nsg to allow http access to the Gateway subnet from LNRS network */
//NOTE: The order of the parameters in the rule is important
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

/* Security rule for app-gateway-nsg to allow http access to the Gateway subnet for Gateway health check */

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

/* Associate the NSG to the Gateway Subnet */
resource "azurerm_subnet_network_security_group_association" "app-gateway-subnet-nsg" {
  subnet_id                 = module.virtual_network.subnet["app-gateway"].id
  network_security_group_id = azurerm_network_security_group.app-gateway-nsg.id
}