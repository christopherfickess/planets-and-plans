# stacks/azure/mattermost-bastion/variable.tf

# -------------------------------
# General / Environment Variables
# -------------------------------
variable "email_contact" {
  description = "Email contact for resource tagging."
  type        = string
}

variable "environment" {
  description = "Environment type (e.g., dev, prod)."
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

# -------------------------------
# AKS Cluster Variables (Optional)
# -------------------------------
variable "aks_cluster_resource_id" {
  description = "Resource ID of the AKS cluster. If not provided and aks_cluster_name is set, will be derived from the cluster name."
  type        = string
  default     = ""
}

# -------------------------------
# Bastion Host Variables
# -------------------------------

variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "bastion_subnet_name" {
  description = "The name of the bastion subnet."
  type        = string
  default     = "AzureBastionSubnet"
}

variable "jumpbox_subnet_name" {
  description = "The name of the jumpbox subnet."
  type        = string
  default     = "jumpbox-subnet"
}

variable "jumpbox_vm_size" {
  description = "VM size for the jumpbox."
  type        = string
  default     = "Standard_B1s"
}

# --------------------------------
# JumpBox Variables
# --------------------------------
variable "jumpbox_admin_username" {
  description = "Admin username for the jumpbox VM."
  type        = string
  default     = "azureuser"
}


# -------------------------------
# End of Variables
# -------------------------------
