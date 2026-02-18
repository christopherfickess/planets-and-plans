# Add IRSA role for NFS

# resource "azurerm_role_assignment" "nfs_users" {
#   depends_on = [module.nfs.nfs_share]

#   scope                = module.nfs.nfs_share_id
#   role_definition_name = "Storage File Data Reader"
#   principal_id         = data.azuread_group.nfs_users.object_id
# }


resource "azurerm_role_assignment" "azure_primary_group_display_name" {
  depends_on = [azurerm_storage_share.nfs_share]

  scope                = azurerm_storage_account.nfs_sa.id
  role_definition_name = "Storage File Data Contributor"
  principal_id         = data.azuread_group.primary_group.object_id
}

