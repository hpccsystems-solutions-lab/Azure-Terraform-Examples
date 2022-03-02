locals {
  app_gateway_backend_address_pool_name             = "tombolo-app-backend-pool"
  app_gateway_api_backend_address_pool_name         = "tombolo-api-app-backend-pool"
  app_gateway_http_setting_name                     = "tombolo-app-http-setting"
  app_gateway_api_http_setting_name                 = "tombolo-api-http-setting"
  app_gateway_frontend_ip_configuration_name        = "tombolo-app-frontend_ip_config_name"
  app_gateway_frontend_port_name                    = "tombolo-app-frontend_port_name"
  app_gateway_http_listener_name                    = "tombolo-app-http-listener-name"
  app_gateway_api_http_listener_name                = "tombolo-api-http-listener-name"
  app_gateway_request_routing_rule_name             = "tombolo-app-request-routing-rule-name"
  app_gateway_api_request_routing_rule_name         = "tombolo-api-request-routing-rule-name"
  api_probe_name                                    = "tombolo-api-health-probe"
  tombolo_mysql_db_name                             = "tombolo-dev-01"
}
