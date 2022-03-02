output "ui_app_service_id" {
  description = "UI app service id"
  value       = {
    id = azurerm_app_service.ui.id
  }
}

output "ui_app_service_profile" {
  description = "Publish profile of UI app service."
  value       = azurerm_app_service.ui.site_credential 
}

output "ui_app_service_outbound_ips" {
  description = "Outbound IPs of UI app service"
  value       = azurerm_app_service.ui.outbound_ip_address_list 
}

output "mysql_fqdn" {
  value = module.mysql.fqdn
}

output "mysql_id" {
  value = module.mysql.id
}

output "subnets" {
  value = {
    subnets = module.virtual_network.subnet
  }
}

output "acr_login_server" {
  value = module.acr.login_server
}
