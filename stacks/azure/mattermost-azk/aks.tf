# stacks/azure/mattermost-azk/aks.tf

resource "azurerm_role_assignment" "aks_admin" {
  depends_on = [module.mattermost_aks]

  scope                = module.mattermost_aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = var.azure_group_principal_id # Mattermost Admins Group Object ID
}

module "mattermost_aks" {
  # depends_on = [module.mattermost_vnet]

  source = "../../../modules/azure/common/aks"

  # Default AKS Module Variables
  kubernetes_version = "1.32.6"

  email_contact       = var.email_contact
  environment         = var.environment
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  unique_name_prefix  = local.base_identifier

  # Subnets from VNet module
  vnet_subnet = {
    id = module.mattermost_vnet.subnets["aks"]
  }

  pod_subnet = {
    id = module.mattermost_vnet.subnets["pods"]
  }


  # Network profile
  net_profile_service_cidr   = var.net_profile_service_cidr
  net_profile_dns_service_ip = var.net_profile_dns_service_ip

  # AKS RBAC groups
  rbac_aad_tenant_id       = data.azurerm_client_config.current.tenant_id
  admin_group_display_name = var.admin_group_display_name
  user_group_display_name  = var.user_group_display_name

  system_node_pool = var.system_node_pool
  node_pools       = var.node_pools

  # Security Settings
  private_cluster_enabled = var.private_cluster_enabled # (bastion required if true)

  tags = merge({ name = "${local.base_identifier}-aks" }, local.tags)
}
