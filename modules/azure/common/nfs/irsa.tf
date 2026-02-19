# RBAC role assignment for Azure Files - SMB only
# NFS shares do not support identity-based RBAC; access is via export policies (IP/CIDR)
resource "azurerm_role_assignment" "azure_primary_group_display_name" {
  count = var.storage_share_enabled_protocol == "SMB" ? 1 : 0

  depends_on = [azurerm_storage_share.nfs_share]

  scope                = azurerm_storage_account.nfs_sa.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = data.azuread_group.primary_group.object_id
}

