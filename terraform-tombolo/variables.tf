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