resource "azurerm_app_service_plan" "tombolo" {
  name                = "tombolo-app-plan"
  location            = module.resource-group.location
  resource_group_name = module.resource-group.name
  kind                = "Linux"
  reserved            = true
  
  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_app_service" "ui" {
  resource_group_name = module.resource-group.name
  location = module.resource-group.location
  
  app_service_plan_id = azurerm_app_service_plan.tombolo.id  
  name        = format("tomboloui-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
  #https_only  = true

  site_config {
    linux_fx_version = "NODE|14-lts" 
  }

}

resource "azurerm_app_service" "api" {
  resource_group_name = module.resource-group.name
  location = module.resource-group.location
  
  app_service_plan_id = azurerm_app_service_plan.tombolo.id  
  name        = format("tomboloapi-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
  https_only  = true

  site_config {
    linux_fx_version = "NODE|14-lts" 
    #ip_restriction = []
    dynamic "ip_restriction"{
      for_each      = toset(azurerm_app_service.ui.outbound_ip_address_list)

      content {
        ip_address  = "${ip_restriction.value}/32"
        action      = "Allow"
        priority    = 300
        name        = "AllowUIAppService"
      }
    }
  }

  depends_on = [module.virtual_network]
}

resource "azurerm_app_service_virtual_network_swift_connection" "api" {
  app_service_id = azurerm_app_service.api.id
  subnet_id      = module.virtual_network.subnet["app-api"].id
}
