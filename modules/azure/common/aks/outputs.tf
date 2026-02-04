
output "aks_module" {
  value = {
    name     = module.aks.aks_name
    id       = module.aks.aks_id
    location = module.aks.location
  }
}

output "aks_id" {
  depends_on = [module.aks]

  value = module.aks.aks_id
}

output "aks_name" {
  value = module.aks.aks_name
}

output "location" {
  value = module.aks.location
}

output "aks_admin_group_object_id" {
  value       = data.azuread_group.aks_admins.object_id
  description = "Object ID of the Azure AD group with admin access to AKS"
}

output "aks_user_group_object_id" {
  value       = data.azuread_group.aks_users.object_id
  description = "Object ID of the Azure AD group with user access to AKS"
}

# output "aks_pde_admin_group_object_id" {
#   value       = data.azuread_group.aks_pde_admins.object_id
#   description = "Object ID of the Azure AD PDE admin group with admin access to AKS"
# }
