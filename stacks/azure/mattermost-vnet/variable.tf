# stacks/azure/mattermost-azk/variable.tf

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
# Azure AD / Group Variables
# -------------------------------
variable "aks_admin_rbac_name" {
  description = "User or service principal UPN that should have cluster-admin binding inside AKS"
  type        = string
}

# -------------------------------
# Networking / Virtual Network Variables
# -------------------------------
variable "address_space" {
  description = "The address space that is used by the Virtual Network."
  type        = list(string)
  # ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_addresses" {
  description = "The address prefixes for the AKS subnet."
  type        = list(string)
  # ["10.0.0.0/24"]
}

# -------------------------------
# End of Azure Mattermost AZK Variables
# -------------------------------
