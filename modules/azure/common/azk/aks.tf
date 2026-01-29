


module "aks" {
  source = "Azure/aks/azurerm"

  version = var.module_version


  # ------------------------------------------------------------------
  # CORE
  # ------------------------------------------------------------------
  prefix              = var.unique_name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version

  aci_connector_linux_enabled = false
  automatic_channel_upgrade   = "stable"
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
  agents_pool_name          = "system"
  agents_size               = "Standard_D4s_v5"
  agents_count              = 3
  auto_scaling_enabled      = true
  agents_min_count          = 3
  agents_max_count          = 10
  agents_type               = "VirtualMachineScaleSets"
  os_disk_size_gb           = 100
  os_disk_type              = "Managed"
  os_sku                    = "Ubuntu"
  agents_availability_zones = ["1", "2", "3"]

  agents_labels = {
    nodepool = "system"
  }

  # ------------------------------------------------------------------
  # ADDITIONAL NODE POOLS
  # ------------------------------------------------------------------
  node_pools = var.node_pools

  # ------------------------------------------------------------------
  # NETWORKING (AZURE CNI)
  # ------------------------------------------------------------------
  network_plugin            = "azure"
  network_policy            = "azure"
  net_profile_outbound_type = "loadBalancer"
  load_balancer_sku         = "standard"

  vnet_subnet = var.vnet_subnets # Fix
  pod_subnet  = var.pod_subnets  # fix

  net_profile_service_cidr   = var.net_profile_service_cidr
  net_profile_dns_service_ip = var.net_profile_dns_service_ip

  # ------------------------------------------------------------------
  # RBAC / AAD
  # ------------------------------------------------------------------
  role_based_access_control_enabled = true

  # fix
  rbac_aad_tenant_id = {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  local_account_disabled = true

  # ------------------------------------------------------------------
  # ADDONS
  # ------------------------------------------------------------------
  azure_policy_enabled = true
  oms_agent_enabled    = true

  key_vault_secrets_provider_enabled = false

  kms_key_vault_key_id = null

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
