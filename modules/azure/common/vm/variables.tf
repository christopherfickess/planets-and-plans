variable "unique_name_prefix" {
  description = "Prefix applied to all resource names — use a short, unique identifier (e.g. mattermost-dev-chris)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the existing resource group to deploy into"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}

variable "email_contact" {
  description = "Owner email address — applied as a tag on all resources"
  type        = string
}

variable "vm_size" {
  description = "Azure VM SKU. Standard_B2s covers CrossGuard functional testing. Increase for production."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Linux admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "subnet_id" {
  description = "Subnet ID to attach the VM primary NIC to"
  type        = string
}

variable "public_ip_enabled" {
  description = "Attach a public IP to the VM. Acceptable for testing — disable for production and route access through Bastion."
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = <<-EOT
    CIDR block allowed to reach port 22.
    Default 0.0.0.0/0 is acceptable for short-lived test deployments only.
    Production: restrict to your office or VPN CIDR e.g. "203.0.113.10/32".
  EOT
  type    = string
  default = "0.0.0.0/0"
}

variable "mattermost_version" {
  description = "Mattermost Docker image tag (e.g. 10.5). Pin to a specific version in production."
  type        = string
  default     = "11.5.1"
}

variable "mattermost_site_url" {
  description = "External URL Mattermost uses for links and redirects. Populated from the VM public IP when left empty."
  type        = string
  default     = ""
}

variable "key_vault_reader_object_ids" {
  description = <<-EOT
    Map of object IDs to grant Key Vault Secrets User on the VM's Key Vault.
    Use this to allow personal Azure identities (e.g. az login users) to read
    the SSH key when Terraform ran as a different identity (e.g. a service principal).
    Keys are arbitrary labels; values are Azure AD object IDs.
    Find your object ID with: az ad signed-in-user show --query id -o tsv
    Example: { chris = "7ced9db5-d867-4820-9fd3-3c777df7c3c8" }
  EOT
  type    = map(string)
  default = {}
}
