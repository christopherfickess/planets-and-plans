variable "unique_name_prefix" {
  description = "Prefix applied to all resource names — use a short, unique identifier (e.g. mattermost-dev-chris)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
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

variable "email_contact" {
  description = "Owner email address — applied as a tag on all resources"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR block for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vm_a_subnet_cidr" {
  description = "CIDR block for VM A's subnet. Each VM gets its own subnet to avoid NSG association conflicts."
  type        = string
  default     = "10.10.1.0/24"
}

variable "vm_b_subnet_cidr" {
  description = "CIDR block for VM B's subnet. Each VM gets its own subnet to avoid NSG association conflicts."
  type        = string
  default     = "10.10.2.0/24"
}

variable "vm_size" {
  description = "Azure VM SKU for the Mattermost host"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Linux admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to reach port 22. Restrict to your IP in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "mattermost_version" {
  description = "Mattermost Docker image tag to deploy (e.g. 11.6.0)"
  type        = string
  default     = "11.6.0"
}

variable "inbound_queue_name" {
  description = "Azure Queue name for CrossGuard inbound messages"
  type        = string
  default     = "crossguard-inbound"
}

variable "outbound_queue_name" {
  description = "Azure Queue name for CrossGuard outbound messages"
  type        = string
  default     = "crossguard-outbound"
}

variable "blob_container_name" {
  description = "Blob container name for CrossGuard file transfers"
  type        = string
  default     = "crossguard-files"
}

# ── Service Principal (externally created) ───────────────────────────────────

variable "enable_service_principal" {
  description = <<-EOT
    Enable service principal RBAC for the CrossGuard plugin. When true, Terraform
    assigns Storage Queue Data Contributor and Storage Blob Data Contributor to
    sp_object_id on the storage account. Requires sp_object_id to be set.
  EOT
  type    = bool
  default = false
}

variable "sp_object_id" {
  description = <<-EOT
    Object ID of the service principal (NOT the client/application ID).
    Used for RBAC role assignments. Find it in Azure Portal under
    Enterprise Applications, or ask your AD admin.
    az ad sp show --id <client-id> --query id -o tsv
  EOT
  type    = string
  default = ""
}


variable "key_vault_reader_object_ids" {
  description = <<-EOT
    Map of Azure AD object IDs granted Key Vault Secrets User on each VM's Key Vault.
    Add your personal identity here when Terraform runs as a service principal so you
    can still fetch SSH keys with az keyvault secret show under az login.
    Find your object ID: az ad signed-in-user show --query id -o tsv
  EOT
  type    = map(string)
  default = {}
}
