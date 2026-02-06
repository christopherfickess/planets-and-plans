# stacks/azure/mattermost-bastion/bastion.tf

# Public IP for Azure Bastion
# # Create Bastion Subnet 
# resource "azurerm_subnet" "bastion" { 
#   depends_on = [data.azurerm_virtual_network.vnet] 
#   name = "AzureBastionSubnet" 
#   resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name 
#   virtual_network_name = data.azurerm_virtual_network.vnet.name 
#   address_prefixes = var.bastion_subnet_addresses 
# } 

# # Create Jumpbox Subnet 
# resource "azurerm_subnet" "jumpbox" { 
#   depends_on = [data.azurerm_virtual_network.vnet] 
#   name = "jumpbox-subnet" 
#   resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name 
#   virtual_network_name = data.azurerm_virtual_network.vnet.name 
#   address_prefixes = var.jumpbox_subnet_addresses 
# } 
# # Public IP for Azure Bastion 
# resource "azurerm_public_ip" "bastion" { 
#   name = "${local.base_identifier}-bastion-pip" 
#   location = data.azurerm_resource_group.mattermost_location.location 
#   resource_group_name = data.azurerm_resource_group.mattermost_location.name 
#   allocation_method = "Static" 
#   sku = "Standard" 
#   tags = merge({ name = "${local.base_identifier}-bastion-pip" }, local.tags) 
# }

resource "azurerm_public_ip" "bastion" {
  name                = "${local.base_identifier}-bastion-pip"
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge({ name = "${local.base_identifier}-bastion-pip" }, local.tags)
}

# Azure Bastion Host
resource "azurerm_bastion_host" "main" {
  # depends_on = [
  #   azurerm_public_ip.bastion
  # ]

  name                = local.bastion_host_name
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  sku = "Standard"
  # Enable tunneling for better performance
  tunneling_enabled = true

  tags = merge({ name = local.bastion_host_name }, local.tags)
}

# Network Security Group for Jumpbox Subnet
resource "azurerm_network_security_group" "jumpbox" {
  name                = local.jumpbox_network_security_group_name
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name

  # Allow inbound from Azure Bastion subnet
  security_rule {
    name                       = "AllowBastionInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = data.azurerm_subnet.bastion.address_prefixes[0]
    destination_address_prefix = "*"
  }

  # Deny all other inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge({ name = local.jumpbox_network_security_group_name }, local.tags)
}

# Associate NSG with Jumpbox Subnet
resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = data.azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

# Network Interface for Jumpbox VM
resource "azurerm_network_interface" "jumpbox" {
  name                = local.jumpbox_network_interface_name
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge({ name = local.jumpbox_network_interface_name }, local.tags)
}

# User Assigned Managed Identity for Jumpbox
resource "azurerm_user_assigned_identity" "jumpbox" {
  name                = local.jumpbox_identifier_name
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name

  tags = merge({ name = local.jumpbox_identifier_name }, local.tags)
}

# Role Assignment: Jumpbox Identity -> AKS Cluster User (if AKS cluster is specified)
resource "azurerm_role_assignment" "jumpbox_aks_cluster_user" {
  depends_on = [data.azurerm_kubernetes_cluster.aks]

  scope                = data.azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}

# Role Assignment: Jumpbox Identity -> Azure Kubernetes Service RBAC Admin (for deployments)
resource "azurerm_role_assignment" "jumpbox_aks_rbac_admin" {
  depends_on = [data.azurerm_kubernetes_cluster.aks]

  scope                = data.azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}

# Jumpbox Virtual Machine
resource "azurerm_linux_virtual_machine" "jumpbox" {
  depends_on = [
    azurerm_network_interface.jumpbox,
    azurerm_user_assigned_identity.jumpbox,
    data.azurerm_kubernetes_cluster.aks
  ]

  name                = local.jumpbox_name
  location            = data.azurerm_resource_group.mattermost_location.location
  resource_group_name = data.azurerm_resource_group.mattermost_location.name
  size                = var.jumpbox_vm_size
  admin_username      = var.jumpbox_admin_username

  network_interface_ids = [azurerm_network_interface.jumpbox.id]

  # Use managed identity for Azure authentication
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.jumpbox.id]
  }

  # Use Ubuntu Server
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = local.jumpbox_os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # SSH Key Authentication
  admin_ssh_key {
    username   = var.jumpbox_admin_username
    public_key = tls_private_key.jumpbox.public_key_openssh
  }

  # Disable password authentication
  disable_password_authentication = true

  # Custom data script to install kubectl, Azure CLI, and configure AKS access
  custom_data = base64encode(templatefile("${path.module}/scripts/jumpbox-setup.sh", {
    AKS_NAME            = local.aks_cluster_name
    RESOURCE_GROUP_NAME = data.azurerm_resource_group.mattermost_location.name
    MANAGED_IDENTITY_ID = azurerm_user_assigned_identity.jumpbox.client_id
    ADMIN_USERNAME      = var.jumpbox_admin_username
  }))

  tags = merge({ name = local.jumpbox_name }, local.tags)
}
