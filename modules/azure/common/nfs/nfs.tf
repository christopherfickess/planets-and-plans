
# Storage account
locals {
  unique_name_prefix = replace(lower(var.unique_name_prefix), "/[^a-z0-9]/", "")
}

resource "azurerm_storage_account" "nfs_sa" {
  name                     = lower("${local.unique_name_prefix}nfs")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind

  # enable_large_file_share  = true
  is_hns_enabled = var.storage_account_is_hns_enabled
  # allow_blob_public_access = false
  min_tls_version = var.storage_account_min_tls_version
  network_rules {
    default_action = var.storage_account_network_rules_default_action
  }
}

# File share with NFS
resource "azurerm_storage_share" "nfs_share" {
  name               = "${var.unique_name_prefix}-${var.storage_share_name}"
  storage_account_id = azurerm_storage_account.nfs_sa.id
  quota              = var.storage_share_quota_gb
  enabled_protocol   = var.storage_share_enabled_protocol
}

# Private endpoint
resource "azurerm_private_endpoint" "nfs_pe" {
  name                = "${var.unique_name_prefix}-nfs-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.aks_subnet.id

  private_service_connection {
    name                           = "${var.unique_name_prefix}-nfs-pe"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.nfs_sa.id
    subresource_names              = ["file"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.unique_name_prefix}-nfs-pe"
  })
}
