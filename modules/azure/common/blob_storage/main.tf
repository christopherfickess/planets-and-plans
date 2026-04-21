# modules/azure/common/blob_storage/main.tf

locals {
  # Storage account names: 3–24 chars, lowercase alphanumeric only — no hyphens.
  # Strip hyphens from the prefix, truncate to 21 chars, append "bs" (blob storage suffix).
  storage_account_name = "${substr(lower(replace(var.unique_name_prefix, "-", "")), 0, 22)}bs"

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ----------------------------------------
# Storage Account — hosts the CrossGuard blob container.
# shared_access_key_enabled is true because the CrossGuard plugin authenticates
# using NewSharedKeyCredential (account key) — it has no managed identity support.
# public_network_access_enabled defaults to true for testing. See variable docstring
# for production guidance.
# ----------------------------------------
resource "azurerm_storage_account" "crossguard" {
  name                          = local.storage_account_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  account_tier                  = "Standard"
  account_replication_type      = var.storage_account_replication_type
  public_network_access_enabled = var.public_network_access_enabled

  shared_access_key_enabled       = true
  default_to_oauth_authentication = false

  # Network rules — only applied when public access is disabled and subnets are provided.
  dynamic "network_rules" {
    for_each = var.public_network_access_enabled ? [] : [1]
    content {
      default_action             = "Deny"
      virtual_network_subnet_ids = var.allowed_subnet_ids
      bypass                     = ["AzureServices"]
    }
  }

  tags = merge(local.tags, { name = local.storage_account_name })
}

# ----------------------------------------
# Blob Container — single shared staging area for CrossGuard file transfers.
# Both federated Mattermost instances read and write here. Private access means
# no anonymous/public URL access — all reads go through authenticated SDK calls
# using the VM's managed identity token.
# ----------------------------------------
resource "azurerm_storage_container" "crossguard_files" {
  name                  = var.blob_container_name
  storage_account_id    = azurerm_storage_account.crossguard.id
  container_access_type = "private"
}

# ----------------------------------------
# RBAC — grant Storage Blob Data Contributor to every VM principal ID in the list.
# for_each over a set so each assignment is tracked independently — adding or
# removing a VM identity won't destroy and recreate the others.
# ----------------------------------------
resource "azurerm_role_assignment" "vm_blob_contributor" {
  depends_on = [azurerm_storage_account.crossguard]

  # Keys (e.g. "vm_a", "vm_b") are static — defined in the stack, not derived from
  # resource attributes — so Terraform can resolve the full key set at plan time.
  for_each = var.vm_principal_ids

  scope                = azurerm_storage_account.crossguard.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}
