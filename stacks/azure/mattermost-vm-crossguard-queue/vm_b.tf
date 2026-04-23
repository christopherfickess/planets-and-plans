# stacks/azure/mattermost-vm-crossguard-queue/vm_b.tf
#
# VM B — second Mattermost instance in the CrossGuard federation pair.
# Prefix gets "-b" appended so all its resources are named distinctly from VM A.

module "vm_b" {
  source = "../../../modules/azure/common/vm"

  unique_name_prefix  = "${var.unique_name_prefix}-b"
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  email_contact       = var.email_contact

  vm_size        = var.vm_size
  admin_username = var.admin_username
  subnet_id      = azurerm_subnet.vm_b.id

  public_ip_enabled = true
  allowed_ssh_cidr  = var.allowed_ssh_cidr

  mattermost_version          = var.mattermost_version
  key_vault_reader_object_ids = var.key_vault_reader_object_ids
}
