
# Grant Key Vault RBAC roles to service account UAMIs.
# Only runs when key_vault_id is set and a service account has key_vault_roles defined.
# Flattened so multiple roles per service account are each a distinct assignment.

locals {
  kv_sa_role_assignments = var.key_vault_id != null ? {
    for pair in flatten([
      for k, v in var.service_accounts : [
        for role in v.key_vault_roles : {
          sa_key = k
          role   = role
        }
      ]
    ]) : "${pair.sa_key}/${pair.role}" => pair
  } : {}
}

resource "azurerm_role_assignment" "kv_service_account" {
  for_each = local.kv_sa_role_assignments

  scope                = var.key_vault_id
  role_definition_name = each.value.role
  principal_id         = azurerm_user_assigned_identity.service_account[each.value.sa_key].principal_id
}
