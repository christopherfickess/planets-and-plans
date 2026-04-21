# modules/azure/common/vm/main.tf

locals {
  # Use the provided site URL, or fall back to the Azure DNS FQDN on port 8065.
  # The FQDN is stable and available immediately — unlike the raw IP it doesn't
  # change if the public IP resource is replaced.
  site_url = var.mattermost_site_url != "" ? var.mattermost_site_url : (
    var.public_ip_enabled ? "http://${azurerm_public_ip.vm[0].fqdn}:8065" : "http://localhost:8065"
  )

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ----------------------------------------
# SSH Key — RSA 4096, generated internally.
# The private key is stored in Key Vault and never appears in outputs.
# Retrieve it post-deploy with:
#   az keyvault secret show --vault-name <vault> --name <secret> --query value -o tsv > vm.pem
#   chmod 600 vm.pem
# ----------------------------------------
resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ----------------------------------------
# Key Vault — holds the generated SSH key pair.
# Naming limit: 24 characters total. Ensure unique_name_prefix stays short enough
# that unique_name_prefix + "-kv" fits under 24 chars (e.g. "mattermost-dev-chris-kv" = 24).
# purge_protection_enabled is false here to allow clean terraform destroy in dev/test.
# Set to true in production to prevent accidental permanent key deletion.
# ----------------------------------------
resource "azurerm_key_vault" "vm" {
  name                       = "${var.unique_name_prefix}-kv"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  enable_rbac_authorization  = true

  tags = merge(local.tags, { name = "${var.unique_name_prefix}-kv" })
}

# Grant the caller (service principal or user running terraform) write access
# so it can store the generated key as a secret.
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.vm.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Grant read-only access to any additional identities in var.key_vault_reader_object_ids.
# Needed when Terraform runs as a service principal but a human uses az login to fetch the SSH key —
# the SP gets Secrets Officer above, but the human's personal identity needs a separate assignment.
resource "azurerm_role_assignment" "kv_secrets_reader" {
  for_each = var.key_vault_reader_object_ids

  scope                = azurerm_key_vault.vm.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

resource "azurerm_key_vault_secret" "vm_private_key" {
  depends_on = [azurerm_role_assignment.kv_secrets_officer]

  name         = "${var.unique_name_prefix}-vm-ssh-private-key"
  value        = tls_private_key.vm.private_key_pem
  key_vault_id = azurerm_key_vault.vm.id
  content_type = "ssh-private-key"
}

resource "azurerm_key_vault_secret" "vm_public_key" {
  depends_on = [azurerm_role_assignment.kv_secrets_officer]

  name         = "${var.unique_name_prefix}-vm-ssh-public-key"
  value        = tls_private_key.vm.public_key_openssh
  key_vault_id = azurerm_key_vault.vm.id
  content_type = "ssh-public-key"
}

# ----------------------------------------
# Public IP — static Standard SKU, conditional on var.public_ip_enabled.
# Disable for production and route access through Bastion instead.
# ----------------------------------------
resource "azurerm_public_ip" "vm" {
  count = var.public_ip_enabled ? 1 : 0

  name                = "${var.unique_name_prefix}-vm-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  # Azure DNS label — gives a free FQDN: <label>.<region>.cloudapp.azure.com
  # Must be lowercase alphanumeric + hyphens, unique within the region.
  # Derived from unique_name_prefix so it stays predictable and doesn't need
  # a separate variable.
  domain_name_label = lower("${var.unique_name_prefix}-vm")

  tags = merge(local.tags, { name = "${var.unique_name_prefix}-vm-pip" })
}

# ----------------------------------------
# NSG — opens SSH (22) from the configured CIDR and Mattermost (8065) from anywhere.
# Restrict allowed_ssh_cidr to a specific IP range in production.
# ----------------------------------------
resource "azurerm_network_security_group" "vm" {
  name                = "${var.unique_name_prefix}-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowMattermost"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8065"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(local.tags, { name = "${var.unique_name_prefix}-vm-nsg" })
}

# Associate the NSG with the subnet passed in from the stack.
resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# ----------------------------------------
# NIC — dynamic private IP, optional public IP attached.
# ----------------------------------------
resource "azurerm_network_interface" "vm" {
  name                = "${var.unique_name_prefix}-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.vm[0].id : null
  }

  tags = merge(local.tags, { name = "${var.unique_name_prefix}-vm-nic" })
}

# ----------------------------------------
# Linux VM — Ubuntu 22.04 LTS Gen2.
# System-assigned managed identity is enabled so the queue_storage module can
# grant it Storage Queue/Blob RBAC roles without a pre-created identity resource.
# Cloud-init installs Docker and launches Mattermost via Compose on first boot.
# ----------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on = [
    azurerm_network_interface.vm,
    azurerm_key_vault_secret.vm_private_key,
  ]

  name                = "${var.unique_name_prefix}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.vm.id]

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.unique_name_prefix}-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vm.public_key_openssh
  }

  disable_password_authentication = true

  custom_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
    mattermost_version  = var.mattermost_version
    mattermost_site_url = local.site_url
  }))

  tags = merge(local.tags, { name = "${var.unique_name_prefix}-vm" })
}
