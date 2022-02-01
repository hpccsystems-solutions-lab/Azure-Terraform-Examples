resource "azurerm_app_service_plan" "tombolo" {
  name                = "tombolo-app-plan"
  location            = azurerm_resource_group.app-tombolo-dev-eastus2.location
  resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name
  kind                = "Linux"
  reserved            = true
  
  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_app_service" "ui" {
  resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name
  location = azurerm_resource_group.app-tombolo-dev-eastus2.location
  
  app_service_plan_id = azurerm_app_service_plan.tombolo.id  
  name        = format("tomboloui-%s-%s", azurerm_resource_group.app-tombolo-dev-eastus2.location, var.private_endpoint_namespace)
  #https_only  = true

  site_config {
    linux_fx_version = "NODE|14-lts" 
  }

}

resource "azurerm_app_service" "api" {
  resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name
  location = azurerm_resource_group.app-tombolo-dev-eastus2.location
  
  app_service_plan_id = azurerm_app_service_plan.tombolo.id  
  name        = format("tomboloapi-%s-%s", azurerm_resource_group.app-tombolo-dev-eastus2.location, var.private_endpoint_namespace)
  https_only  = true

  site_config {
    linux_fx_version = "NODE|14-lts" 
    ip_restriction = []
    /*dynamic "ip_restriction"{
      for_each      = toset(azurerm_app_service.ui.outbound_ip_address_list)

      content {
        ip_address  = "${ip_restriction.value}/32"
        action      = "Allow"
        priority    = 300
        name        = "AllowUIAppService"
      }
    }*/
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "api" {
  app_service_id = azurerm_app_service.api.id
  subnet_id      = data.azurerm_subnet.tombolo-subnets_ids["app-api"].id
}
