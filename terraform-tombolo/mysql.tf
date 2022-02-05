resource "random_string" "random" {
  length  = 12
  upper   = false
  special = false
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

module "mysql" {
  source = "git@github.com:LexisNexis-RBA/terraform-azurerm-mysql-server.git"
 
  location                = module.metadata.location
  resource_group_name     = module.resource-group.name
  names                   = module.metadata.names
  tags                    = module.metadata.tags
 
  server_id               = random_string.random.result
  administrator_login     = "tombolo-sqladmin"
  administrator_password  = var.mysql-admin-pwd

  #service_endpoints   = {"env1" = module.virtual_network.subnet["iaas-outbound"].id}
  access_list         = {"LNRS_VPN" = {
                          start_ip_address = chomp(data.http.my_ip.body), 
                          end_ip_address = chomp(data.http.my_ip.body)
                        }}
  databases           = { "tombolo" = {charset = "utf16", collation = "utf16_general_ci"} }

  private_endpoints   = {
    "tombolo-mysql" = module.virtual_network.subnet["private-endpoints"].id
  }

  threat_detection_policy = {
    enable_threat_detection_policy   = true
    threat_detection_email_addresses = ["hpcc-solutions-lab@lexisnexisrisk.com"]
  }

 
}