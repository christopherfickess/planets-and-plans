# stacks/azure/mattermost-bastion/locals.tf

locals {
  date            = formatdate("YYYY-DD-MM", time_static.deployment_date.rfc3339)
  base_identifier = "mattermost-${var.environment}"

  # AKS Cluster Resources
  aks_cluster_name = "${local.base_identifier}-aks"

  # Bastion Host Resources
  bastion_host_name      = "${local.base_identifier}-bastion"
  bastion_public_ip_name = "${local.base_identifier}-bastion-pip"

  # Jumpbox Resources
  jumpbox_identifier_name             = "${local.base_identifier}-jumpbox-identity"
  jumpbox_name                        = "${local.base_identifier}-jumpbox"
  jumpbox_network_security_group_name = "${local.base_identifier}-jumpbox-nsg"
  jumpbox_os_disk_name                = "${local.base_identifier}-jumpbox-osdisk"

  # Key Vault Resources
  keyvault_name                    = "${local.base_identifier}-jb"
  keyvault_pub_key_secret_name     = "${local.base_identifier}-jumpbox-ssh-public-key"
  keyvault_private_key_secret_name = "${local.base_identifier}-jumpbox-ssh-private-key"

  # Network Interface Resources
  jumpbox_network_interface_name = "${local.base_identifier}-jumpbox-nic"

  # ssh key resource name
  ssh_key_name = "${local.base_identifier}-ssh-key"

  # VNet Resources
  vnet_name = "${local.base_identifier}-vnet"

  tags = {
    Date           = time_static.deployment_date.rfc3339,
    Email          = var.email_contact,
    Env            = var.environment,
    Resource_Group = var.resource_group_name,
    Type           = "Bastion Host"
    Deployment     = "Terraform"
  }
}
