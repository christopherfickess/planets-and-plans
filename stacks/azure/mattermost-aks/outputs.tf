
# -------------------------------------------------------
# Cluster identity
# -------------------------------------------------------
output "aks_id" {
  value       = module.mattermost_aks.aks_id
  description = "Resource ID of the AKS cluster."
}

output "aks_name" {
  value       = module.mattermost_aks.aks_name
  description = "Name of the AKS cluster."
}

output "oidc_issuer_url" {
  value       = module.mattermost_aks.oidc_issuer_url
  description = "OIDC issuer URL — needed when creating federated identity credentials outside Terraform."
}

# -------------------------------------------------------
# Workload identity — one entry per service account
# -------------------------------------------------------
output "workload_identity" {
  value = {
    for k in keys(module.mattermost_aks.identity_client_ids) : k => {
      client_id    = module.mattermost_aks.identity_client_ids[k]
      principal_id = module.mattermost_aks.identity_principal_ids[k]
      annotation   = "azure.workload.identity/client-id: \"${module.mattermost_aks.identity_client_ids[k]}\""
      namespace    = local.service_account_names[k].namespace
    }
  }
  description = "Per service account: client_id, principal_id, ready-to-paste annotation, and namespace."
}

# -------------------------------------------------------
# RBAC group IDs
# -------------------------------------------------------
output "aks_admin_group_object_id" {
  value       = module.mattermost_aks.aks_admin_group_object_id
  description = "Object ID of the Azure AD group with admin access to AKS."
}

output "aks_user_group_object_id" {
  value       = module.mattermost_aks.aks_user_group_object_id
  description = "Object ID of the Azure AD group with user access to AKS."
}

# -------------------------------------------------------
# Connection instructions
# -------------------------------------------------------
output "current_time" {
  value = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
}

output "connect_cluster" {
  value       = <<-EOT
Set the subscription context to the AKS cluster's subscription:

az account set --subscription ${data.azurerm_subscription.current.subscription_id}

To connect to the AKS cluster, run the following command:
az aks get-credentials \
  --resource-group ${var.resource_group_name} \
  --name ${module.mattermost_aks.aks_name}

Update your kubeconfig with the AKS cluster credentials:
kubelogin azurecli \
  --subscription-id ${data.azurerm_subscription.current.subscription_id} \
  --resource-group ${var.resource_group_name} \
  --name ${module.mattermost_aks.aks_name}
EOT
  description = "Instructions for connecting to the AKS cluster."
}
