data "azurerm_subnet" "tombolo-subnets_ids" {
  #for_each = {for subnet in tolist(azurerm_virtual_network.tombolo-dev-eastus2-vnet.subnet): subnet.name => subnet}
  for_each = {for subnet in tolist(azurerm_virtual_network.tombolo-dev-eastus2-vnet.subnet): subnet.name => subnet}
  name = each.key
  #id = each.value
  virtual_network_name = azurerm_virtual_network.tombolo-dev-eastus2-vnet.name
  resource_group_name  = azurerm_resource_group.app-tombolo-dev-eastus2.name
}

module "tombolo_ui_private_endpoint" {  
  source              = "github.com/LexisNexis-RBA/terraform-azurerm-private-endpoint.git"
  namespace           = var.private_endpoint_namespace
  resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name

  resources = [
    {
      id  = azurerm_app_service.ui.id
      name  = format("tomboloui-%s-%s", azurerm_resource_group.app-tombolo-dev-eastus2.location, var.private_endpoint_namespace)
      resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name
      location            = module.metadata.location
      network = {
        vnet_id   = azurerm_virtual_network.tombolo-dev-eastus2-vnet.id
        subnet_id = data.azurerm_subnet.tombolo-subnets_ids["app-ui"].id
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

  depends_on = [azurerm_app_service.ui]
}