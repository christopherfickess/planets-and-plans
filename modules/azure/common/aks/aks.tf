# modules/azure/common/aks/aks.tf


module "aks" {
  depends_on = [azuread_group.aks_admins, azuread_group.aks_users]
  source     = "Azure/aks/azurerm"
  version    = "11.0.0" # pick the version you want

  # ------------------------------------------------------------------
  # CORE SETTINGS
  # ------------------------------------------------------------------
  prefix              = var.unique_name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version

  aci_connector_linux_enabled = false
  sku_tier                    = "Standard"
  support_plan                = "KubernetesOfficial"

  # ------------------------------------------------------------------
  # IDENTITY
  # ------------------------------------------------------------------
  identity_type = "SystemAssigned"

  # For UserAssigned:
  # identity_type = "UserAssigned"
  # identity_ids  = [azurerm_user_assigned_identity.aks.id]

  # ------------------------------------------------------------------
  # DEFAULT (SYSTEM) NODE POOL
  # ------------------------------------------------------------------
  agents_pool_name          = var.system_node_pool.name
  agents_size               = var.system_node_pool.vm_size
  agents_count              = var.system_node_pool.node_count
  auto_scaling_enabled      = var.system_node_pool.auto_scaling_enabled
  agents_min_count          = var.system_node_pool.min_count
  agents_max_count          = var.system_node_pool.max_count
  agents_type               = "VirtualMachineScaleSets" # or could be var.system_node_pool.node_type if needed
  os_disk_size_gb           = var.system_node_pool.os_disk_size_gb
  os_disk_type              = var.system_node_pool.os_disk_type
  os_sku                    = var.system_node_pool.os_type
  agents_availability_zones = var.system_node_pool.availability_zones
  agents_labels             = var.system_node_pool.node_labels

  # ------------------------------------------------------------------
  # ADDITIONAL NODE POOLS
  # ------------------------------------------------------------------
  node_pools = var.node_pools

  # ------------------------------------------------------------------
  # NETWORKING
  # ------------------------------------------------------------------
  network_plugin            = "azure"
  network_policy            = "azure"
  net_profile_outbound_type = "loadBalancer"
  load_balancer_sku         = "standard"
  network_plugin_mode       = var.network_plugin_mode

  vnet_subnet = var.vnet_subnet # Fix
  pod_subnet  = var.pod_subnet  # Fix

  net_profile_service_cidr   = var.net_profile_service_cidr
  net_profile_dns_service_ip = var.net_profile_dns_service_ip

  # ------------------------------------------------------------------
  # RBAC / AAD
  # ------------------------------------------------------------------
  role_based_access_control_enabled = true

  rbac_aad_tenant_id              = var.rbac_aad_tenant_id
  rbac_aad_azure_rbac_enabled     = true
  rbac_aad_admin_group_object_ids = [azuread_group.aks_admins.id]

  local_account_disabled = true

  # ------------------------------------------------------------------
  # ADDONS
  # ------------------------------------------------------------------
  azure_policy_enabled = true
  oms_agent_enabled    = true

  # Work on this in the future
  key_vault_secrets_provider_enabled = false
  kms_key_vault_key_id               = null

  # ------------------------------------------------------------------
  # STORAGE / CSI DRIVERS
  # ------------------------------------------------------------------
  storage_profile_disk_driver_enabled         = true
  storage_profile_file_driver_enabled         = true
  storage_profile_blob_driver_enabled         = false
  storage_profile_snapshot_controller_enabled = true

  # ------------------------------------------------------------------
  # MAINTENANCE WINDOW
  # ------------------------------------------------------------------
  maintenance_window = {
    allowed = [
      {
        day   = "Sunday"
        hours = [1, 2, 3]
      }
    ]
  }

  # ------------------------------------------------------------------
  # SECURITY SETTINGS
  # ------------------------------------------------------------------
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  private_cluster_enabled   = var.private_cluster_enabled

  # DNS PRIVATE ZONE Examples:
  # private_dns_zone_id = "System"   # Let Azure manage the private DNS zone
  # OR
  # private_dns_zone_id = <your_dns_zone_id>  # Bring your own

  # ------------------------------------------------------------------
  # TAGS
  # ------------------------------------------------------------------
  tags = {
    environment    = var.environment
    owner          = "platform"
    managed_by     = "terraform"
    email_contact  = var.email_contact
    location       = var.location
    module_version = var.module_version
  }
}

