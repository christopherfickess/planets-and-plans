##############################################
#                 AMI / EC2                  #
##############################################
variable "ami_type" {
  description = "The AMI name pattern to use for the EC2 instance."
  type        = string
  default     = "al2023-ami-2023*"
}

variable "ec2_iam_role_name" {
  description = "The name of the IAM role to attach to the EC2 instance."
  type        = string
  default     = "ec2-role"
}

variable "ec2_iam_role_policy_name" {
  description = "The name of the IAM role policy."
  type        = string
  default     = "ec2-role-policy"
}

variable "ec2_instance_name" {
  description = "The name of the EC2 instance."
  type        = string
  default     = "mattermost-ec2-instance"
}

variable "ec2_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the EC2 instance."
  type        = string
  default     = "ec2-instance-profile"
}

variable "ec2_instance_size" {
  description = "The size of the EC2 instance."
  type        = string
  default     = "t3.medium"
}

variable "ec2_security_group_name" {
  description = "The name of the EC2 security group."
  type        = string
  default     = "mattermost-ec2-sg"
}

variable "key_pair_local_path" {
  description = "The local path to the SSH key pair file."
  type        = string
  default     = "~/.ssh/mattermost-ec2-key.pem"
}

variable "key_pair_name" {
  description = "The name of the SSH key pair to use for the EC2 instance."
  type        = string
  default     = "mattermost-ec2-key"
}

variable "root_volume_size" {
  description = "The size of the root volume in GB."
  type        = number
  default     = 25
}

##############################################
#                ACCOUNT / IAM               #
##############################################
variable "account_role_name" {
  description = "AWS primary role that needs access to deployed resources."
  type        = string
}

variable "mattermost_kms_key_alias" {
  description = "Default KMS alias."
  type        = string
  default     = "alias/ec2-root-key"
}

##############################################
#               NETWORK / VPC                #
##############################################
variable "subnet_private_tag_name_1" {
  description = "Subnet tag name 1."
  type        = string
}

variable "subnet_private_tag_name_2" {
  description = "Subnet tag name 2."
  type        = string
}

variable "subnet_public_tag_name" {
  description = "Public subnet tag name."
  type        = string
}

variable "subnet_rds_private_tag_name" {
  description = "Subnet tag name for the RDS subnet group."
  type        = string
  default     = "mattermost-rds-subnet-group"
}

variable "vpc_tag_name" {
  description = "VPC tag name."
  type        = string
}

##############################################
#                 RDS / Database             #
##############################################
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
  default     = "mattermostdb-ec2"
}

variable "rds_db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "MattermostdbEC2ChrisDev"
}

variable "rds_db_policy_name" {
  description = "Name of the RDS database policy."
  type        = string
  default     = "Mattermost-RDS-Access-Policy"
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

variable "rds_security_group_name" {
  description = "The name of the RDS security group."
  type        = string
  default     = "mattermost-rds-sg"
}

##############################################
#                 ROUTE53 / DNS              #
##############################################

variable "domain_user_email" {
  description = "Admin email used for domain-related notifications."
  type        = string
}

variable "validation_method" {
  description = "Certificate validation method."
  type        = string
  default     = "DNS"
}

##############################################
#                 S3 / Storage               #
##############################################
variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "ec2-mattermost-bucket"
}

variable "s3_bucket_policy_name" {
  description = "Name of the S3 bucket policy."
  type        = string
  default     = "mattermost-s3-bucket-policy"
}

##############################################
#                 SSM / Automation           #
##############################################
variable "parameter_store_path_prefix" {
  description = "Prefix for SSM parameter names."
  type        = string
  default     = "/mattermost-dev-self-hosted"
}

variable "ssm_run_command_name" {
  description = "Name of the SSM document that runs shell commands."
  type        = string
  default     = "MattermostDevDeployment"
}

##############################################
#                Mattermost App              #
##############################################
variable "mattermost_version" {
  description = "Default Mattermost version to install."
  type        = string
  default     = "11.1.0"
}


##############################################
#                Region Settings             #
##############################################
variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "region" {
  description = "AWS region for deployment (duplicate option)."
  type        = string
  default     = "us-east-1"
}

##############################################
#             Unique Naming Values           #
##############################################
variable "unique_id" {
  description = "Unique ID for tagging and naming."
  type        = string
}

variable "unique_name_suffix" {
  description = "Unique suffix for resource naming."
  type        = string
}

##############################################
#                   END                      #
##############################################
