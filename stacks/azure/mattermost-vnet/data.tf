# stacks/azure/mattermost-azk/data.tf


data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
# data "azurerm_countries" "all" {}
# data "azurerm_locations" "available" {
# subscription_id = data.azurerm_subscription.current.subscription_id
# }


data "azurerm_resource_group" "mattermost_location" {
  name = var.resource_group_name
}

resource "time_static" "deployment_date" {
  triggers = {
    always_run = "true" # optional, to force creation only once
  }
}

output "current_time" {
  value = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
}
output "aks_subnet_id" {
  value       = data.azurerm_subnet.aks.id
  description = "The ID of the AKS subnet."
}


# Module VNET Data
data "azurerm_virtual_network" "vnet" {
  depends_on = [module.mattermost_vnet]

  name                = local.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "aks" {
  depends_on = [module.mattermost_vnet]

  name                 = var.aks_subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}
