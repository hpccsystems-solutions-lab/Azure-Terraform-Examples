module "tombolo_runner" {
  source = "github.com/LexisNexis-RBA/terraform-azure-vm-github-runner.git"

  resource_group_name = module.resource-group.name
  location            = module.resource-group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id           = module.virtual_network.subnet["github-runner"].id

  #custom_ubuntu_image_id = data.azurerm_shared_image.shared.id
  runner_os           = "linux"
  runner_scope        = "repo"
  runner_name         = "tombolo-runner"
  github_org_name     = "hpcc-systems"
  github_repo_name    = "Tombolo"
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.tombolo_runner_token

  enable_boot_diagnostics     = false
  use_managed_storage_account = false

  runner_labels = ["azure", "dev"]
}

## grant acr push role to vm
resource "azurerm_role_assignment" "tombolo_acrpush" {
  scope                = module.resource-group.id
  role_definition_name = "AcrPush"
  principal_id         = module.tombolo_runner.principal_id

  depends_on = [module.tombolo_runner]
}

/*resource "azurerm_role_assignment" "acrpull" {
  scope                = module.resource-group.id
  role_definition_name = "AcrPull"
  principal_id         = module.tombolo_runner.principal_id

  depends_on = [module.tombolo_runner]
}*/

## grant Reader role to vm
/*resource "azurerm_role_assignment" "rgreader" {
  scope                = module.resource-group.id
  role_definition_name = "Reader"
  principal_id         = module.tombolo_runner.principal_id

  depends_on = [module.tombolo_runner]
}*/

## grant Website Contributor role to vm
resource "azurerm_role_assignment" "tombolo_rgwebsitecontributor" {
  scope                = module.resource-group.id
  role_definition_name = "Website Contributor"
  principal_id         = module.tombolo_runner.principal_id

  depends_on = [module.tombolo_runner]
}

/*resource "azurerm_role_assignment" "rgcontributor" {
  scope                = module.resource-group.id
  role_definition_name = "Contributor"
  principal_id         = module.tombolo_runner.principal_id

  depends_on = [module.tombolo_runner]
}*/