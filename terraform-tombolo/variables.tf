variable "subscription_id" {
  description = "subscription id"
  type        = string
}

variable "names" {
  description = "Names to be applied to resources"
  type        = map(string)
}

variable "tags" {
  description = "tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
   type = map
   default = {
      app-gateway = {
         type = "app-gateway"
         cidr = ["10.1.1.0/26"]
         delegations = {           
         }     
      }
      app-ui = {
         type = "app-ui"
         cidr = ["10.1.1.128/27"]
         delegations = {            
         }     
      }
      app-api = {
         type = "app-api"
         cidr = ["10.1.1.160/27"]
         delegations = {
            "delegation" = {
               name    = "Microsoft.Web/serverFarms"
               actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
            }
         }   
      }      
   }
}

variable "app-ui-subnet" {
  description = "UI App service subnet id"
  type        = string
  default     = "app-ui"
}

variable "private_endpoint_namespace" {
  description = "Private Endpoint Namespace"
  type        = string
  default     = "dev"

}

variable "mysql-admin-pwd" {
   description = "MySQL Admin password"
   type        = string
   sensitive   = true
}