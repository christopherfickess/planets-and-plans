# stacks/azure/mattermost-azk/aks.tf

data "azuread_group" "aks_pde_admins" {
  display_name = var.azure_pde_admin_group_display_name
}

resource "azurerm_role_assignment" "aks_pde_admins" {
  scope                = module.mattermost_aks.aks_id
  role_definition_name = "Azure Kubernetes Service RBAC Admin" # Built-in role
  principal_id         = data.azuread_group.aks_pde_admins.object_id
}

resource "azurerm_role_assignment" "aks_admin" {
  depends_on = [module.mattermost_aks]

  scope                = module.mattermost_aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = data.azuread_group.pde_group.object_id
}

module "mattermost_aks" {
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
    id = data.azurerm_subnet.aks.id
  }
  pod_subnet = null # or var.pod_subnet if used

  # Network profile
  net_profile_service_cidr   = var.net_profile_service_cidr
  net_profile_dns_service_ip = var.net_profile_dns_service_ip

  # AKS RBAC groups
  rbac_aad_tenant_id = data.azurerm_client_config.current.tenant_id
  # azure_pde_admin_group_display_name = var.azure_pde_admin_group_display_name
  aks_admin_rbac_name      = var.aks_admin_rbac_name
  admin_group_display_name = local.admin_group_display_name
  user_group_display_name  = local.user_group_display_name

  system_node_pool = var.system_node_pool
  node_pools       = var.node_pools

  # Security Settings
  private_cluster_enabled = var.private_cluster_enabled # (bastion required if true)

  # Storage settings for Azure Files
  deploy_storage                   = var.deploy_storage
  storage_account_name             = local.storage_account_name
  storage_share_name               = local.storage_share_name
  storage_share_quota_gb           = var.storage_share_quota_gb
  storage_account_tier             = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type

  tags = merge({ name = "${local.base_identifier}-aks-cluster" }, local.tags)
}
