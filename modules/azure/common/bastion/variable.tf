# modules/azure/common/bastion/variable.tf

# -------------------------------
# General Variables
# -------------------------------
variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

# -------------------------------
# Networking — IDs passed from stack
# -------------------------------
variable "bastion_subnet_id" {
  description = "ID of the AzureBastionSubnet."
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix of the bastion subnet (used in NSG inbound rule)."
  type        = string
}

variable "jumpbox_subnet_id" {
  description = "ID of the jumpbox subnet."
  type        = string
}

# -------------------------------
# AKS
# -------------------------------
variable "aks_cluster_id" {
  description = "Resource ID of the AKS cluster for role assignments."
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster (embedded in the cloud-init setup script)."
  type        = string
}

# -------------------------------
# Azure AD
# -------------------------------
variable "azure_pde_group_object_id" {
  description = "Object ID of the Azure PDE group granted Key Vault Secrets User on the jumpbox vault."
  type        = string
}

# -------------------------------
# Jumpbox VM
# -------------------------------
variable "jumpbox_vm_size" {
  description = "VM size for the jumpbox."
  type        = string
  default     = "Standard_B1s"
}

variable "jumpbox_admin_username" {
  description = "Admin username for the jumpbox VM."
  type        = string
  default     = "azureuser"
}

# -------------------------------
# Name suffixes
# -------------------------------
variable "bastion_pip_name" {
  description = "Suffix appended to unique_name_prefix for the Bastion public IP name."
  type        = string
  default     = "bastion-pip"
}

variable "bastion_host_name" {
  description = "Suffix appended to unique_name_prefix for the Bastion host name."
  type        = string
  default     = "bastion"
}

variable "jumpbox_nsg_name" {
  description = "Suffix appended to unique_name_prefix for the jumpbox NSG name."
  type        = string
  default     = "jumpbox-nsg"
}

variable "jumpbox_nic_name" {
  description = "Suffix appended to unique_name_prefix for the jumpbox NIC name."
  type        = string
  default     = "jumpbox-nic"
}

variable "jumpbox_identity_name" {
  description = "Suffix appended to unique_name_prefix for the jumpbox managed identity name."
  type        = string
  default     = "jumpbox-identity"
}

variable "jumpbox_vm_name" {
  description = "Suffix appended to unique_name_prefix for the jumpbox VM name."
  type        = string
  default     = "jumpbox"
}

variable "jumpbox_os_disk_name" {
  description = "Suffix appended to unique_name_prefix for the jumpbox OS disk name."
  type        = string
  default     = "jumpbox-osdisk"
}

variable "keyvault_name" {
  description = "Suffix appended to unique_name_prefix for the jumpbox Key Vault name."
  type        = string
  default     = "jb"
}

variable "keyvault_private_key_secret_name" {
  description = "Suffix appended to unique_name_prefix for the SSH private key secret name."
  type        = string
  default     = "jumpbox-ssh-private-key"
}

variable "keyvault_public_key_secret_name" {
  description = "Suffix appended to unique_name_prefix for the SSH public key secret name."
  type        = string
  default     = "jumpbox-ssh-public-key"
}
