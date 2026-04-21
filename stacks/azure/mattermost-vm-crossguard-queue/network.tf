# stacks/azure/mattermost-vm-crossguard-queue/network.tf
#
# Two VMs get separate subnets so the vm module can associate an NSG with each
# independently. If they shared one subnet, both module calls would try to create
# an azurerm_subnet_network_security_group_association for the same subnet and
# Terraform would error on the duplicate.
#
# For production: add a NAT gateway, remove public IPs from the VMs,
# and restrict storage account access to these subnets.

resource "azurerm_virtual_network" "crossguard" {
  depends_on = [data.azurerm_resource_group.crossguard]

  name                = "${var.unique_name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]

  tags = merge(local.tags, { name = "${var.unique_name_prefix}-vnet" })
}

# Subnet for VM A (instance 1 of the federation pair)
resource "azurerm_subnet" "vm_a" {
  name                 = "${var.unique_name_prefix}-vm-a-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.crossguard.name
  address_prefixes     = [var.vm_a_subnet_cidr]
}

# Subnet for VM B (instance 2 of the federation pair)
resource "azurerm_subnet" "vm_b" {
  name                 = "${var.unique_name_prefix}-vm-b-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.crossguard.name
  address_prefixes     = [var.vm_b_subnet_cidr]
}
