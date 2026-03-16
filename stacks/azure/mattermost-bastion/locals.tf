# stacks/azure/mattermost-bastion/locals.tf

locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  # AKS Cluster Resources
  aks_cluster_name = "${var.unique_name_prefix}-aks"

  # Bastion Host Resources
  bastion_host_name      = "${var.unique_name_prefix}-bastion"
  bastion_public_ip_name = "${var.unique_name_prefix}-bastion-pip"

  # Jumpbox Resources
  jumpbox_identifier_name             = "${var.unique_name_prefix}-jumpbox-identity"
  jumpbox_name                        = "${var.unique_name_prefix}-jumpbox"
  jumpbox_network_security_group_name = "${var.unique_name_prefix}-jumpbox-nsg"
  jumpbox_os_disk_name                = "${var.unique_name_prefix}-jumpbox-osdisk"

  # Key Vault Resources
  keyvault_name                    = "${var.unique_name_prefix}-jb"
  keyvault_pub_key_secret_name     = "${var.unique_name_prefix}-jumpbox-ssh-public-key"
  keyvault_private_key_secret_name = "${var.unique_name_prefix}-jumpbox-ssh-private-key"

  # Network Interface Resources
  jumpbox_network_interface_name = "${var.unique_name_prefix}-jumpbox-nic"

  # ssh key resource name
  ssh_key_name = "${var.unique_name_prefix}-ssh-key"

  # VNet Resources
  vnet_name = "${var.unique_name_prefix}-vnet"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "Bastion Host"
    Deployment     = "Terraform"
  }
}
