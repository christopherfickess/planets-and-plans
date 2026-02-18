resource "azurerm_user_assigned_identity" "service_account" {
  for_each = var.service_accounts

  name                = each.value.uami_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "service_account_fed" {
  depends_on = [module.aks]
  for_each   = azurerm_user_assigned_identity.service_account

  name                = "${each.key}-federated"
  parent_id           = each.value.id
  resource_group_name = var.resource_group_name
  issuer              = module.aks.oidc_issuer_url
  audience            = ["api://AzureADTokenExchange"] # required
  subject             = "system:serviceaccount:${var.service_accounts[each.key].namespace}:${each.key}"
  # description = "Allows ${each.key} in ${var.service_accounts[each.key].namespace} to authenticate to Azure Key Vault from AKS"
}

