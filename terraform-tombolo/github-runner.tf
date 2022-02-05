module "runner" {
  source = "github.com/LexisNexis-RBA/terraform-azure-vm-github-runner.git"

  resource_group_name = module.resource-group.name
  location            = module.resource-group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  subnet_id           = module.virtual_network.subnet["github-runner"].id

  #custom_ubuntu_image_id = data.azurerm_shared_image.shared.id
  runner_os = "linux"
  runner_scope        = "repo"
  runner_name         = "hpccsollab-runner"
  github_org_name     = "alfjjacob"
  github_repo_name    = "Tombolo"
  ## gen repo runner token https://github.community/t/api-to-generate-runners-token/16963
  github_runner_token = var.runner_token

  enable_boot_diagnostics     = true
  use_managed_storage_account = false

  runner_labels = ["azure", "dev"]
}

## grant runner mi owner rights to sub
/*resource "azurerm_role_assignment" "sub" {
  scope                = data.azurerm_subscription.current.subscription_id
  role_definition_name = "Contributor"
  principal_id         = module.runner.principal_id

  depends_on = [module.runner]
}*/