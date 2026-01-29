# -------------------------------
# General Variables
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
  # default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group for Terraform state."
  type        = string
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

# -------------------------------
# Azure Group Variables
# -------------------------------
variable "admin_group_display_name" {
  description = "Display name for the Azure AD admin group."
  type        = string
}

variable "user_group_display_name" {
  description = "Display name for the Azure AD user group."
  type        = string
}


# -------------------------------
# AZK Resources Variables
# -------------------------------
variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster."
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS cluster nodes."
  type        = string
  default     = "Standard_D2_v2"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
  default     = "mattermost-aks"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "mattermost-aks-cluster"
}

variable "aks_default_node_pool_name" {
  description = "Default node pool name for the AKS cluster."
  type        = string
  default     = "default"
}

variable "enable_azure_monitoring" {
  description = "Enable Azure Monitor for the AKS cluster."
  type        = bool
  default     = true
}

# -------------------------------
# End of AZK Resources Variables
# -------------------------------
