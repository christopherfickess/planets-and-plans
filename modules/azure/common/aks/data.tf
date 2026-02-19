data "azurerm_client_config" "current" {}

data "azuread_group" "aks_admins" {
  display_name = var.admin_group_display_name
}

data "azuread_group" "aks_users" {
  display_name = var.user_group_display_name
}

