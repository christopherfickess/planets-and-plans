
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

variable "module_version" {
  description = "Version of the module."
  type        = string
  default     = "11.0.0"
}

variable "resource_group_name" {
  description = "Name of the resource group for Terraform state."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}

variable "unique_name_prefix" {
  description = "Unique prefix for resource naming."
  type        = string
}

# -------------------------------
# DNS Record Variables
# -------------------------------
variable "azure_primary_group_display_name" {
  description = "Display name of the Azure AD group to grant access to the Key Vault."
  type        = string
}

variable "keyvault_name" {
  description = "Name of the Azure Key Vault."
  type        = string
  default    = "kv" 
}

variable "purge_protection_enabled" {
  description = "Enable purge protection. Once enabled, cannot be disabled. Set to true to match existing Key Vaults that have it enabled."
  type        = bool
  default     = true
}