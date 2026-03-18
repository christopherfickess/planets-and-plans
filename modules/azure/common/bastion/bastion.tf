# modules/azure/common/bastion/bastion.tf

resource "azurerm_public_ip" "bastion" {
  name                = "${var.unique_name_prefix}-${var.bastion_pip_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, { name = "${var.unique_name_prefix}-${var.bastion_pip_name}" })
}

resource "azurerm_bastion_host" "main" {
  name                = "${var.unique_name_prefix}-${var.bastion_host_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  sku               = "Standard"
  tunneling_enabled = true

  tags = merge(var.tags, { name = "${var.unique_name_prefix}-${var.bastion_host_name}" })
}

resource "azurerm_network_security_group" "jumpbox" {
  name                = "${var.unique_name_prefix}-${var.jumpbox_nsg_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowBastionInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.bastion_subnet_address_prefix
    destination_address_prefix = "*"
  }

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

  tags = merge(var.tags, { name = "${var.unique_name_prefix}-${var.jumpbox_nsg_name}" })
}

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = var.jumpbox_subnet_id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.unique_name_prefix}-${var.jumpbox_nic_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(var.tags, { name = "${var.unique_name_prefix}-${var.jumpbox_nic_name}" })
}

resource "azurerm_user_assigned_identity" "jumpbox" {
  name                = "${var.unique_name_prefix}-${var.jumpbox_identity_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, { name = "${var.unique_name_prefix}-${var.jumpbox_identity_name}" })
}

resource "azurerm_role_assignment" "jumpbox_aks_cluster_user" {
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}

resource "azurerm_role_assignment" "jumpbox_aks_rbac_admin" {
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = azurerm_user_assigned_identity.jumpbox.principal_id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  depends_on = [
    azurerm_network_interface.jumpbox,
    azurerm_user_assigned_identity.jumpbox,
  ]

  name                = "${var.unique_name_prefix}-${var.jumpbox_vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.jumpbox_vm_size
  admin_username      = var.jumpbox_admin_username

  network_interface_ids = [azurerm_network_interface.jumpbox.id]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.jumpbox.id]
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9_7"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.unique_name_prefix}-${var.jumpbox_os_disk_name}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  admin_ssh_key {
    username   = var.jumpbox_admin_username
    public_key = tls_private_key.jumpbox.public_key_openssh
  }

  disable_password_authentication = true

  custom_data = base64encode(templatefile("${path.module}/scripts/jumpbox-centos-setup.yaml", {
    AKS_NAME            = var.aks_cluster_name
    ADMIN_USERNAME      = var.jumpbox_admin_username
    MANAGED_IDENTITY_ID = azurerm_user_assigned_identity.jumpbox.client_id
    PUBLIC_KEY_CONTENT  = tls_private_key.jumpbox.public_key_openssh
    RESOURCE_GROUP_NAME = var.resource_group_name
  }))

  tags = merge(var.tags, { name = "${var.unique_name_prefix}-${var.jumpbox_vm_name}" })
}
