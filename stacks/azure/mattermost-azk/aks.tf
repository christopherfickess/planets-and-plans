

locals {
  tags = {
    Email          = var.email_contact,
    Env            = var.environment,
    Type           = "AKS Cluster",
    Location       = var.location,
    Resource_Group = var.resource_group_name
  }
}

module "mattermost_aks" {
  depends_on = [module.mattermost_vnet]

  source = "../../modules/azure/mattermost/aks"

  # Default AKS Module Variables
  email_contact       = var.email_contact
  environment         = var.environment
  location            = azurerm_resource_group.mattermost_location.location
  resource_group_name = azurerm_resource_group.mattermost_location.name
  unique_name_prefix  = local.base_identifier

  # 
  cluster_name   = "${local.base_identifier}-aks"
  dns_prefix     = "${local.base_identifier}-dns"
  node_count     = var.aks_node_count
  vm_size        = var.aks_vm_size
  vnet_subnet_id = module.mattermost_vnet.subnets["aks-subnet"].id


  tags = merge({ name = "${local.base_identifier}-aks" },
  local.tags)
}
