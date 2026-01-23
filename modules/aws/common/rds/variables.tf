
variable "subnet_rds_private_tag_name" {
  description = "Subnet tag name for the RDS subnet group."
  type        = string
}

variable "rds_security_group_name" {
  description = "The name of the RDS security group."
  type        = string
}

variable "mattermost_db_password" {
  description = "Password for the RDS database admin user."
  type        = string
  sensitive   = true
}

variable "mattermost_db_username" {
  description = "Username for the RDS database admin user."
  type        = string
}

variable "rds_db_identifier" {
  description = "The identifier for the RDS database instance."
  type        = string
}

variable "rds_db_name" {
  description = "The name of the RDS database."
  type        = string
}

variable "rds_db_policy_name" {
  description = "Name of the RDS database policy."
  type        = string
}

variable "rds_db_type" {
  description = "Database engine type."
  type        = string
  default     = "postgres"
}

variable "rds_db_version" {
  description = "Postgres engine version."
  type        = string
  default     = "default.postgres17"
}

variable "rds_instance_type" {
  description = "The RDS instance type."
  type        = string
  default     = "db.t3.medium"
}

variable "mattermost_rds_role_name" {
  description = "The name of the IAM role for RDS access."
  type        = string
}

variable "parameter_store_path_prefix" {
  description = "Prefix for SSM parameter names."
  type        = string
}

variable "tags" {
  description = "Tags to be added to resources in RDS"
  type        = map(string)
}

variable "assume_role_policy_json" {
  description = "The JSON policy document that grants an entity permission to assume the role."
  type        = string
}

variable "mattermost_rds_policy_json" {
  description = "The JSON policy document that defines the permissions for the RDS IAM role."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where RDS will be deployed."
  type        = string
}

variable "mattermost_eks_security_group_id" {
  description = "The security group ID for the Mattermost EKS cluster."
  type        = string
}

# KMS Variables
variable "kms_deletion_window_in_days" {
  description = "Number of days before the KMS key is deleted after being scheduled for deletion."
  type        = number
  default     = 30
}

variable "kms_key_policy_json" {
  description = "The JSON policy document that defines the permissions for the KMS key."
  type        = string
}
variable "rds_kms_alias_name" {
  description = "The name of the KMS alias for the RDS instance."
  type        = string
}
