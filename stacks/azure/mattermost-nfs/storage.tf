
# Storage account
resource "azurerm_storage_account" "nfs_sa" {
  depends_on = [data.azurerm_kubernetes_cluster.aks]

  name                     = local.private_dns_a_record_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  # enable_large_file_share  = true
  is_hns_enabled = false
  # allow_blob_public_access = false
  min_tls_version = "TLS1_2"
  network_rules {
    default_action = "Deny"
  }
}

# File share with NFS
resource "azurerm_storage_share" "nfs_share" {
  name               = local.storage_share_name
  storage_account_id = azurerm_storage_account.nfs_sa.id
  quota              = 100
  enabled_protocol   = "NFS"
}
