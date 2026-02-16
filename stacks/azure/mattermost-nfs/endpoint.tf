
# Private endpoint
resource "azurerm_private_endpoint" "nfs_pe" {
  name                = local.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.aks_subnet.id

  private_service_connection {
    name                           = local.private_endpoint_name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.nfs_sa.id
    subresource_names              = ["file"]
  }
}
