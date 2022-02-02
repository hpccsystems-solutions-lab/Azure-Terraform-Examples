# Public Ip
resource "azurerm_public_ip" "app_gw" {
  name                = format("appgateway-pip-%s-%s", "tombolo", module.resource-group.location)
  location            = module.metadata.location
  resource_group_name = module.resource-group.name  
  allocation_method   = "Static"
  sku                 = "Standard"

  tags                = module.metadata.tags  
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "tombolo-app-gateway" {
  location            = module.metadata.location
  resource_group_name = module.resource-group.name  
  name                = format("appgw-tombolo-%s-%s", module.resource-group.location, var.private_endpoint_namespace)
  
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = module.virtual_network.subnet["app-gateway"].id
  }

  sku {
    capacity = 2
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }

  backend_address_pool    {
    name                  = local.app_gateway_backend_address_pool_name
    ip_addresses          = null
    fqdns                 = [azurerm_app_service.ui.default_site_hostname]    
  }

  backend_http_settings   {  
    name                  = local.app_gateway_http_setting_name
    path                  = ""
    cookie_based_affinity = "Disabled"
    pick_host_name_from_backend_address = true
    port                  = 80
    protocol              = "http"
    request_timeout       = 20
  }

  frontend_ip_configuration {
    name                  = local.app_gateway_frontend_ip_configuration_name
    public_ip_address_id  = azurerm_public_ip.app_gw.id
  }

  frontend_port {
    name = local.app_gateway_frontend_port_name
    port = 80
  }

  http_listener {
    name                           = local.app_gateway_http_listener_name
    frontend_ip_configuration_name = local.app_gateway_frontend_ip_configuration_name
    frontend_port_name             = local.app_gateway_frontend_port_name
    protocol                       = "Http"
    ssl_certificate_name           = ""
  }

  request_routing_rule {
    name                       = local.app_gateway_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.app_gateway_http_listener_name
    backend_address_pool_name  = local.app_gateway_backend_address_pool_name
    backend_http_settings_name = local.app_gateway_http_setting_name
  }

  ssl_policy {
    policy_type = "Custom"
    policy_name = "AppGwSslPolicy20170401S"
    cipher_suites = [
      "TLS_DHE_DSS_WITH_AES_128_CBC_SHA",
      "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256",
    ]
    min_protocol_version = "TLSv1_2"
  }  

  firewall_policy_id = azurerm_web_application_firewall_policy.ui.id
  
  depends_on = [azurerm_app_service.ui]
}