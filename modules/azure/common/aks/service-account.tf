resource "azurerm_user_assigned_identity" "service_account" {
  for_each = length(var.service_accounts) > 0 ? tomap({ for sa in var.service_accounts : sa => sa }) : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
}
