# stacks/azure/mattermost-bastion/data.tf

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "mattermost_location" {
  name = var.resource_group_name
}

resource "time_static" "deployment_date" {
  triggers = {
    always_run = "true"
  }
}

# VNet Data
data "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "bastion" {
  name                 = var.bastion_subnet_name
  resource_group_name  = data.azurerm_resource_group.mattermost_location.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_subnet" "jumpbox" {
  name                 = var.jumpbox_subnet_name
  resource_group_name  = data.azurerm_resource_group.mattermost_location.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}
