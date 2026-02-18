
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {
  subscription_id = data.azurerm_client_config.current.subscription_id
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azuread_group" "primary_group" {
  display_name = var.azure_primary_group_display_name
}
