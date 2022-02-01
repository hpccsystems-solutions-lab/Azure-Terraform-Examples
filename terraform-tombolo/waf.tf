resource "azurerm_web_application_firewall_policy" "ui" {
  resource_group_name = azurerm_resource_group.app-tombolo-dev-eastus2.name
  location            = module.metadata.location
  name                = "tombolouiwaf"

  custom_rules {
    name              = "IPRestriction"
    priority          = 1
    rule_type         = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = true
      match_values       = [data.http.my_ip.body]
    }

    action = "Block"
  }

  managed_rules {    
    managed_rule_set {
      type    = "OWASP"
      version = "3.1"      
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

}