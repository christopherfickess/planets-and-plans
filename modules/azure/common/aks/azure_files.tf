

locals {
  storage_account_name = lower(replace("${var.unique_name_prefix}${var.storage_account_suffix}", "/[^a-z0-9]/", ""))
  storage_share_name   = "${var.unique_name_prefix}-${var.storage_share_suffix}"
}

resource "azurerm_storage_account" "mattermost_storage" {
  count = var.deploy_storage ? 1 : 0

  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  tags                     = merge(var.tags, { Name = local.storage_account_name })
}

resource "azurerm_storage_share" "mattermost_share" {
  count = var.deploy_storage ? 1 : 0

  name               = local.storage_share_name
  storage_account_id = azurerm_storage_account.mattermost_storage[count.index].id
  quota              = var.storage_share_quota_gb
  # enabled_protocols  = ["NFS"]
}
