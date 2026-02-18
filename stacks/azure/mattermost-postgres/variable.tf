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
# Networking / Virtual Network Variables
# -------------------------------
variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "db_subnet_name" {
  description = "The name of the database subnet."
  type        = string
  default     = "db-subnet"
}

variable "database_names" {
  description = "List of database names to create on the PostgreSQL server. Example: [\"my_db1\", \"my_db2\"]"
  type        = list(string)
  default     = ["mattermost"]
}

variable "server_version" {
  description = "The version of the PostgreSQL server."
  type        = string
  default     = "15"
}

# variable "vnet_rules" {
#   description = "List of VNet rules to apply to the PostgreSQL server."
#   type = list(object({
#     name      = string
#     subnet_id = string
#   }))
#   # default = []
#   # { name = "subnet1", subnet_id = "<subnet_id>" }
# }

# -------------------------------
# Storage Size Variable
# -------------------------------
variable "storage_mb" {
  description = "The storage size in MB for the PostgreSQL server."
  type        = number
  default     = 32768
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL server."
  type        = string
  default     = "B_Standard_B1ms"
}

# -------------------------------
# Key Vault Variables
# -------------------------------
variable "keyvault_name_admin_user" {
  description = "Admin username for the PostgreSQL server."
  type        = string
  default     = "postgresadmin"
}

variable "keyvault_name_admin_password" {
  description = "Key vault name for PostgreSQL admin password."
  type        = string
  default     = "postgres-admin-password"
}

variable "db_admin_username" {
  description = "Database admin username."
  type        = string
  default     = "mmcloudadmin"
}

# Internal DB user and password variables
variable "keyvault_name_internal_user" {
  description = "Internal username for the PostgreSQL server."
  type        = string
  default     = "postgresinternaluser"
}

variable "keyvault_name_internal_password" {
  description = "Key vault name for PostgreSQL internal password."
  type        = string
  default     = "postgres-internal-password"
}

variable "db_internal_username" {
  description = "Database internal username."
  type        = string
  default     = "mm_cloud"
}

variable "db_internal_schema_name" {
  description = "Database internal schema name."
  type        = string
  default     = "mattermost_internal"
}



# -------------------------------
# Service Account Variables
# -------------------------------
variable "external_secrets_uami_name" {
  description = "User-assigned managed identity name for external secrets."
  type        = string
  default     = "external-secrets"
}

# -------------------------------
# DNS Variables
# -------------------------------
variable "azure_pde_admin_group_display_name" {
  description = "Display name for the Azure PDE admin group."
  type        = string
  default     = "Azure PDE"
}

variable "private_dns_zone_name" {
  description = "The name of the private DNS zone."
  type        = string
  default     = "privatelink.postgres.database.azure.com"
}

variable "postgres_dns_name" {
  description = "The DNS name for the PostgreSQL server."
  type        = string
  default     = "mattermost-postgres"
}

# -------------------------------
# End of Azure Mattermost AZK Variables
# -------------------------------

variable "backup_retention_days" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo redundant backup replication across regions."
  type        = bool
  default     = false
}

variable "db_collation" {
  description = "Database collation for sorting and comparison rules."
  type        = string
  default     = "en_US.utf8"
}

variable "db_charset" {
  description = "Character set encoding for the databases."
  type        = string
  default     = "UTF8"
}


variable "public_network_access_enabled" {
  description = "Enable or disable public network access to the PostgreSQL server."
  type        = bool
  default     = false
}
