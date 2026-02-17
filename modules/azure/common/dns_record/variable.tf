
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
}

variable "mattermost_domain" {
    description = "Custom domain for Mattermost deployment."
  type        = string
  default     = "<customer>.<env>.cloud.mattermost.com"
}

variable "vnet_name" {
  description = "Name of VNET"
  type = string
}