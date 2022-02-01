#existing resource group
resource "azurerm_resource_group" "app-tombolo-dev-eastus2" {
  name     = "app-tombolo-dev-eastus2"
  location = module.metadata.location
  tags     = module.metadata.tags
}
