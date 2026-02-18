
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

variable "azure_primary_group_display_name" {
  description = "Display name of the Azure AD group to grant access to the NFS."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

# -------------------------------
# Storage Variables
# -------------------------------

variable "storage_share_name" {
  description = "Name of the storage share."
  type        = string
  default     = "nfs-share"
}

variable "storage_share_quota_gb" {
  description = "Quota for the storage share in GB."
  type        = number
  default     = 100
}

variable "storage_share_enabled_protocol" {
  description = "Enabled protocol for the storage share."
  type        = string
  default     = "NFS"
}

variable "storage_account_tier" {
  description = "Tier for the storage account."
  type        = string
  default     = "Premium"
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account."
  type        = string
  default     = "LRS"
}

variable "storage_account_kind" {
  description = "Kind for the storage account."
  type        = string
  default     = "FileStorage"
}

variable "storage_account_is_hns_enabled" {
  description = "Whether to enable Hierarchical Namespace for the storage account."
  type        = bool
  default     = false
}

variable "storage_account_min_tls_version" {
  description = "Minimum TLS version for the storage account."
  type        = string
  default     = "TLS1_2"
}

variable "storage_account_network_rules_default_action" {
  description = "Default action for the storage account network rules."
  type        = string
  default     = "Deny"
}
