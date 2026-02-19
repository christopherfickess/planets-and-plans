# -----------------------------------------------------------------------------
# LoadBalancer RBAC - Grant AKS cluster identity Network Contributor on PIP resource group
# -----------------------------------------------------------------------------
# When using azure-pip-name annotation (PIP in same or different RG), the Azure cloud
# provider needs to read/attach the public IP. The cloud provider runs in the control
# plane and uses the cluster identity (not kubelet identity) for these operations.
# Set load_balancer_resource_group to the RG containing the PIP (from mattermost-vnet).
# -----------------------------------------------------------------------------

data "azurerm_kubernetes_cluster" "cluster" {
  name                = module.aks.aks_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  count = var.grant_load_balancer_network_access ? 1 : 0

  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${coalesce(var.load_balancer_resource_group, var.resource_group_name)}"
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}
