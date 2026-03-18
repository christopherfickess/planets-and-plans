# modules/azure/common/aks/irsa.tf

# resource "azurerm_role_assignment" "aks_users" {
#   depends_on = [module.aks.aks_id]

#   scope                = module.aks.aks_id
#   role_definition_name = "Azure Kubernetes Service Cluster User Role"
#   principal_id         = data.azuread_group.aks_users.object_id
# }

data "azuread_group" "cluster_admin" {
  count = var.manage_entra_groups ? 0 : 1

  display_name     = var.admin_group_display_name
  security_enabled = true

  lifecycle {
    postcondition {
      condition     = self.object_id != null
      error_message = <<-EOT
        Group "${self.display_name}" not found in Entra ID.
        An admin must create this group before running plan:

          az ad group create \
            --display-name "${self.display_name}" \
            --mail-nickname "${self.display_name}" \
            --description "Cluster admin group for ${var.unique_name_prefix}"
      EOT
    }
  }
}

data "azuread_group" "cluster_user" {
  count = var.manage_entra_groups ? 0 : 1

  display_name     = var.user_group_display_name
  security_enabled = true

  lifecycle {
    postcondition {
      condition     = self.object_id != null
      error_message = <<-EOT
        Group "${self.display_name}" not found in Entra ID.
        An admin must create this group before running plan:

          az ad group create \
            --display-name "${self.display_name}" \
            --mail-nickname "${self.display_name}" \
            --description "Cluster user group for ${var.unique_name_prefix}"
      EOT
    }
  }
}
# groups.tf
resource "azuread_group" "cluster_admin" {
  count = var.manage_entra_groups ? 1 : 0

  display_name     = "${var.unique_name_prefix}-cluster-admin"
  description      = "Azure AD group for cluster admin"
  security_enabled = true
  visibility       = "Private"
  mail_enabled     = false
  mail_nickname    = "${var.unique_name_prefix}-cluster-admin"
}

resource "azuread_group" "cluster_user" {
  count = var.manage_entra_groups ? 1 : 0

  display_name     = "${var.unique_name_prefix}-cluster-user"
  description      = "Azure AD group for cluster user"
  security_enabled = true
  visibility       = "Private"
  mail_enabled     = false
  mail_nickname    = "${var.unique_name_prefix}-cluster-user"
}

locals {
  cluster_admin_object_id = var.manage_entra_groups ? azuread_group.cluster_admin[0].object_id : data.azuread_group.cluster_admin[0].object_id
  cluster_user_object_id  = var.manage_entra_groups ? azuread_group.cluster_user[0].object_id : data.azuread_group.cluster_user[0].object_id
}
# role_assignments.tf
resource "azurerm_role_assignment" "cluster_admin" {
  depends_on = [module.aks]

  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = local.cluster_admin_object_id
}

resource "azurerm_role_assignment" "cluster_user" {
  depends_on = [module.aks]

  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = local.cluster_user_object_id
}
