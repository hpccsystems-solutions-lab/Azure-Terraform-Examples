data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

module "mysql" {
  source = "git@github.com:LexisNexis-RBA/terraform-azurerm-mysql-server.git"
 
  location                = module.metadata.location
  resource_group_name     = module.resource-group.name
  names                   = module.metadata.names
  tags                    = module.metadata.tags
  #a unique identification for the db server
  server_id               = "01"
  administrator_login     = "tombolo-sqladmin"
  administrator_password  = var.mysql-admin-pwd

  #service_endpoints   = {"env1" = module.virtual_network.subnet["iaas-outbound"].id}
  #allowing LNRS VPN to connect. Ideally, public_network_access_enabled should be set to false, but the LNRS MySQL module does not support it (maybe for a reason)
  #disabling public access will restrict access from on-perm, which would probably require additional setup (express-route/private dns connection etc) 
  access_list         = {"LNRS_VPN" = {
                          start_ip_address = chomp(data.http.my_ip.body), 
                          end_ip_address = chomp(data.http.my_ip.body)
                        }}
  databases           = { "tombolo" = {charset = "utf16", collation = "utf16_general_ci"} }

  threat_detection_policy = {
    enable_threat_detection_policy   = true
    threat_detection_email_addresses = ["hpcc-solutions-lab@lexisnexisrisk.com"]
  }
}

#allowing access from api subnet
resource "azurerm_mysql_virtual_network_rule" "tombolo-mysql-vnet-rule" {
  name                = "allow-tombolo-backend-api"
  resource_group_name = module.resource-group.name
  server_name         = local.tombolo_mysql_db_name
  subnet_id           = module.virtual_network.subnet["app-api"].id
}