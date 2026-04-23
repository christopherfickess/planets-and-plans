# modules/azure/common/queue_storage/main.tf

locals {
  # Storage account names: 3–24 chars, lowercase alphanumeric only — no hyphens.
  # Strip hyphens from the prefix, truncate to 22 chars, append "cg" (CrossGuard suffix).
  storage_account_name = "${substr(lower(replace(var.unique_name_prefix, "-", "")), 0, 22)}cg"

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ----------------------------------------
# Storage Account — hosts queues and the blob container.
# public_network_access_enabled defaults to true for testing with no private endpoint.
# Production: set to false and add a private endpoint so the VM accesses storage
# over the VNet without traversing the public internet.
# ----------------------------------------
resource "azurerm_storage_account" "crossguard" {
  name                          = local.storage_account_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  account_tier                  = "Standard"
  account_replication_type      = var.storage_account_replication_type
  public_network_access_enabled = var.public_network_access_enabled

  # shared_access_key_enabled is true because the CrossGuard plugin authenticates
  # using NewSharedKeyCredential (account key) — it has no managed identity support.
  shared_access_key_enabled       = true
  default_to_oauth_authentication = false

  # Network rules — only applied when public access is disabled and specific
  # subnets are provided. Leave empty for test environments with public access.
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
# Queues — inbound (external → this Mattermost) and outbound (this → external).
# CrossGuard uses these to bridge messages between federated Mattermost instances.
# ----------------------------------------
resource "azurerm_storage_queue" "inbound" {
  name                 = var.inbound_queue_name
  storage_account_name = azurerm_storage_account.crossguard.name
}

resource "azurerm_storage_queue" "outbound" {
  name                 = var.outbound_queue_name
  storage_account_name = azurerm_storage_account.crossguard.name
}

# ----------------------------------------
# Blob Container — used by CrossGuard for file attachment transfers.
# ----------------------------------------
resource "azurerm_storage_container" "crossguard_files" {
  name                  = var.blob_container_name
  storage_account_id    = azurerm_storage_account.crossguard.id
  container_access_type = "private"
}

# ----------------------------------------
# RBAC — grant each VM's managed identity read/write access to queues and blobs.
# for_each over a set so each assignment is tracked independently — adding or
# removing a VM identity won't destroy and recreate the others.
# ----------------------------------------
resource "azurerm_role_assignment" "vm_queue_contributor" {
  depends_on = [azurerm_storage_account.crossguard]

  # Keys (e.g. "vm_a", "vm_b") are static — defined in the stack, not derived from
  # resource attributes — so Terraform can resolve the full key set at plan time.
  for_each = var.principal_ids

  scope                = azurerm_storage_account.crossguard.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "vm_blob_contributor" {
  depends_on = [azurerm_storage_account.crossguard]

  for_each = var.principal_ids

  scope                = azurerm_storage_account.crossguard.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}
