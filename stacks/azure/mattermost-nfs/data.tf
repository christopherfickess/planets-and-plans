# Ensure Terraform waits for AKS cluster
data "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_name
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "aks_vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
}
