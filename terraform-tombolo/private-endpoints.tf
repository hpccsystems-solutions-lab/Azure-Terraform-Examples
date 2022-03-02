/*data "azurerm_subnet" "tombolo-subnets_ids" {
  #for_each = {for subnet in tolist(azurerm_virtual_network.tombolo-dev-eastus2-vnet.subnet): subnet.name => subnet}
  for_each = {for subnet in tolist(module.virtual_network.subnet): subnet.name => subnet}
  name = each.key
  #id = each.value
}*/

# PE to UI App Services 
module "tombolo_ui_private_endpoint" {  
  source              = "github.com/LexisNexis-RBA/terraform-azurerm-private-endpoint.git"
  namespace           = var.private_endpoint_namespace
  resource_group_name = module.resource-group.name

  resources = [
    {
      id  = azurerm_app_service.ui2.id
      name  = format("tomboloui2-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
      resource_group_name = module.resource-group.name
      location            = module.metadata.location
      network = {
        vnet_id   = module.virtual_network.vnet.id
        subnet_id = module.virtual_network.subnet["private-endpoints"].id
      }
    }
  ]

  private_service_connection = {
    subresource_names = ["sites"]
  }

  private_dns_zone_name = "privatelink.azurewebsites.net"
  include_dns_vnet_link  = true

  private_dnszone_enabled = true
  public_dnszone_enabled  = false

  depends_on = [azurerm_app_service.ui2, module.virtual_network]
}

# PE to API App Services 
module "tombolo_api_private_endpoint" {  
  source              = "github.com/LexisNexis-RBA/terraform-azurerm-private-endpoint.git"
  namespace           = var.private_endpoint_namespace
  resource_group_name = module.resource-group.name

  resources = [
    {
      id  = azurerm_app_service.api.id
      name  = format("tomboloapi-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
      resource_group_name = module.resource-group.name
      location            = module.metadata.location
      network = {
        vnet_id   = module.virtual_network.vnet.id
        subnet_id = module.virtual_network.subnet["private-endpoints"].id
      }
    }
  ]

  private_service_connection = {
    subresource_names = ["sites"]
  }

  private_dns_zone_name = null
  include_dns_vnet_link  = false

  private_dnszone_enabled = true
  public_dnszone_enabled  = false

  depends_on = [azurerm_app_service.api, module.virtual_network]
}

resource "azurerm_private_dns_a_record" "tombolo-api" {
  name                = "tomboloapi-eastus2-dev"
  zone_name           = "privatelink.azurewebsites.net"
  resource_group_name = module.resource-group.name
  ttl                 = 3600
  records             = ["10.1.0.197"] //TO:DO Fetch the IP from the output endpoint module
  depends_on = [azurerm_app_service.api, module.tombolo_api_private_endpoint]
}

resource "azurerm_private_dns_a_record" "tombolo-api-scm" {
  name                = "tomboloapi-eastus2-dev.scm"
  zone_name           = "privatelink.azurewebsites.net"
  resource_group_name = module.resource-group.name
  ttl                 = 3600
  records             = ["10.1.0.197"] //TO:DO Fetch the IP from the output endpoint module
  depends_on          = [azurerm_app_service.api, module.tombolo_api_private_endpoint]
}

resource "azurerm_private_dns_a_record" "tombolo-ui-scm" {
  name                = "tomboloui2-eastus2-dev.scm"
  zone_name           = "privatelink.azurewebsites.net"
  resource_group_name = module.resource-group.name
  ttl                 = 3600
  records             = ["10.1.0.196"] //TO:DO Fetch the IP from the output endpoint module
  depends_on          = [azurerm_app_service.ui2, module.tombolo_ui_private_endpoint]
}

module "tombolo_mysql_private_endpoint" {  
  source              = "github.com/LexisNexis-RBA/terraform-azurerm-private-endpoint.git"
  namespace           = var.private_endpoint_namespace
  resource_group_name = module.resource-group.name

  resources = [
    {
      id  = module.mysql.id
      name  = format("tombolomysql-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
      resource_group_name = module.resource-group.name
      location            = module.metadata.location
      network = {
        vnet_id   = module.virtual_network.vnet.id
        subnet_id = module.virtual_network.subnet["private-endpoints"].id
      }
    }
  ]

  private_service_connection = {
    subresource_names = ["mysqlServer"]
  }

  private_dns_zone_name = "privatelink.mysql.database.azure.com"
  include_dns_vnet_link  = true

  private_dnszone_enabled = true
  public_dnszone_enabled  = false

  depends_on = [module.mysql]
}
