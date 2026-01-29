
module "mattermost_vnet" {
  source = "../../modules/azure/common/vnet"

  vnet_name           = "${local.base_identifier}-vnet"
  resource_group_name = azurerm_resource_group.mattermost_location.name
  location            = azurerm_resource_group.mattermost_location.location

  tags = merge({ name = "${local.base_identifier}-vnet" }, local.tags)
}
