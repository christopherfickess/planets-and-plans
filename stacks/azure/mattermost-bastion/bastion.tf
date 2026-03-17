# stacks/azure/mattermost-bastion/bastion.tf

module "bastion" {
  source = "../../../modules/azure/common/bastion"

  unique_name_prefix  = var.unique_name_prefix
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.mattermost_location.location
  tags                = local.tags

  bastion_subnet_id             = data.azurerm_subnet.bastion.id
  bastion_subnet_address_prefix = data.azurerm_subnet.bastion.address_prefixes[0]
  jumpbox_subnet_id             = data.azurerm_subnet.jumpbox.id

  aks_cluster_id   = data.azurerm_kubernetes_cluster.aks.id
  aks_cluster_name = local.aks_cluster_name

  azure_pde_group_object_id = data.azuread_group.azure_pde.object_id

  jumpbox_vm_size        = var.jumpbox_vm_size
  jumpbox_admin_username = var.jumpbox_admin_username
}
