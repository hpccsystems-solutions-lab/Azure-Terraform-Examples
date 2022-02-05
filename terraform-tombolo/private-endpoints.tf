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
      id  = azurerm_app_service.ui.id
      name  = format("tomboloui-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
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

  depends_on = [azurerm_app_service.ui, module.virtual_network]
}