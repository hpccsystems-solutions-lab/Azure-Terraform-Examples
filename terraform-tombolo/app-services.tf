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
    #linux_fx_version = "NODE|14-lts" 
    linux_fx_version    = "DOCKER|${chomp(module.acr.login_server)}/tombolo-ui"
    acr_use_managed_identity_credentials  = true
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT"  =  "false"
    "acrUseManagedIdentityCreds"      =  "true"
    "WEBSITE_PULL_IMAGE_OVER_VNET"    = "true"
    "DOCKER_REGISTRY_SERVER_URL"      = "${chomp(module.acr.login_server)}"

  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [module.acr]
}

#appservice identity role for interacting with acr
resource "azurerm_role_assignment" "ui_app_service_acr_role" {
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
  principal_id         = azurerm_app_service.ui.identity[0].principal_id
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
        ip_address  = "${chomp(ip_restriction.value)}/32"
        action      = "Allow"
        priority    = 300
        name        = "AllowUIAppService"
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }  

  depends_on = [module.virtual_network]
}

#appservice identity role for interacting with acr
resource "azurerm_role_assignment" "api_app_service_acr_role" {
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
  principal_id         = azurerm_app_service.api.identity[0].principal_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "api" {
  app_service_id = azurerm_app_service.api.id
  subnet_id      = module.virtual_network.subnet["app-api"].id
}
