
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
variable "private_dns_zone_vnet_link_name" {
  description = "Name for the private DNS zone virtual network link."
  type        = string
  default     = "dns-link"
}

variable "dns_zone_name" {
  description = "Name of the DNS zone."
  type        = string
  # default     = "<customer>.<env>.cloud.mattermost.com"
  # default     = "privatelink.postgres.database.azure.com"
  # default     = "privatelink.postgres.database.azure.com"
}

variable "vnet_name" {
  description = "Name of VNET"
  type        = string
}

variable "registration_enabled" {
  description = "Whether to register the DNS zone with the private DNS zone."
  type        = bool
  default     = false
}
