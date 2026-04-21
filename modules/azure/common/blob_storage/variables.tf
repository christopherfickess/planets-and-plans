variable "unique_name_prefix" {
  description = "Prefix applied to all resource names — use a short, unique identifier (e.g. mm-cg-blob-dev)"
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

variable "storage_account_replication_type" {
  description = <<-EOT
    Storage replication type.
    LRS: single region, three copies — sufficient for testing and single-region prod.
    GRS or RAGRS: cross-region redundancy — use for production when regional failover matters.
  EOT
  type    = string
  default = "LRS"
}

variable "blob_container_name" {
  description = "Name of the blob container used for CrossGuard file transfer staging."
  type        = string
  default     = "crossguard-files"
}

variable "vm_principal_ids" {
  description = <<-EOT
    Map of managed identity principal IDs to grant Storage Blob Data Contributor on the
    storage account. Keys must be static strings (e.g. "vm_a", "vm_b") — Terraform uses
    them as for_each keys at plan time so they cannot be derived from resource attributes.
    Values are the principal IDs, which may be known only after apply.
    Example: { vm_a = module.vm_a.vm_principal_id, vm_b = module.vm_b.vm_principal_id }
  EOT
  type    = map(string)
  default = {}
}

variable "public_network_access_enabled" {
  description = <<-EOT
    Allow access to the storage account from the public internet.
    true is acceptable for testing with no private endpoint.
    Production: set to false and deploy a private endpoint so VMs access
    Blob Storage over the VNet without traversing the public internet.
  EOT
  type    = bool
  default = true
}

variable "allowed_subnet_ids" {
  description = <<-EOT
    List of subnet IDs permitted to access the storage account via network rules.
    Leave empty when public_network_access_enabled is true.
    Production: populate with both VM subnet IDs and set public_network_access_enabled = false.
  EOT
  type    = list(string)
  default = []
}
