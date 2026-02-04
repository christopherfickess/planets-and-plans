

# resource "kubernetes_cluster_role_binding_v1" "aks_admin_binding" {
#   depends_on = [module.aks]

#   metadata {
#     name = "aks-admin-binding" # Name of the ClusterRoleBinding
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io" # API group for RBAC
#     kind      = "ClusterRole"               # Binding to built-in ClusterRole
#     name      = "cluster-admin"             # Built-in role
#   }

#   subject {
#     kind      = "Group"                          # or "User" if using UPN
#     name      = data.azuread_group.aks_admins.id # Add Azure AD group Object ID or UPN here
#     api_group = "rbac.authorization.k8s.io"      # API group for RBAC
#   }
# }
