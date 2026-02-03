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

# Module VNET Data
data "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  virtual_network_name = module.mattermost_vnet.vnet_name
  resource_group_name  = data.azurerm_resource_group.mattermost_location.name
}

data "azurerm_subnet" "pods" {
  name                 = "pods-subnet"
  virtual_network_name = module.mattermost_vnet.vnet_name
  resource_group_name  = data.azurerm_resource_group.mattermost_location.name
}
