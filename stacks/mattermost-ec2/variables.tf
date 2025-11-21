# Variables with Defaults and Descriptions

variable "ami_type" {
  description = "The AMI name pattern to use for the EC2 instance."
  type        = string
  default     = "al2023-ami-2023*"
}

variable "admin_access" {
  description = "Enable or disable admin access."
  type        = string
  default     = "aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_d1e9700799a73262"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "ec2_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the EC2 instance."
  type        = string
  default     = "ec2-instance-profile"
}

variable "ec2_instance_name" {
  description = "The name of the EC2 instance."
  type        = string
  default     = "mattermost-ec2-instance"
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

variable "mattermost_kms_key_alias" {
  description = "[String]Default KMS Alias"
  type        = string
  default     = "alias/ec2-root-key"

}
variable "mattermost_version" {
  description = "[String]Default Mattermost Version to Install"
  type        = string
  default     = "11.1.0"
}

variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "rds_db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "MattermostdbEC2ChrisDev"
}

variable "rds_db_identifier" {
  description = "The name of the RDS database."
  type        = string
  default     = "mattermostdb-ec2"
}

variable "rds_db_type" {
  description = "[String]Default RDS Database type"
  type        = string
  default     = "postgres"
}

variable "rds_db_version" {
  description = "[String]Default RDS Database Postgres Version"
  type        = string
  default     = "default.postgres17"
}

variable "rds_db_policy_name" {
  description = "The name of the RDS database policy"
  type        = string
  default     = "Mattermost-RDS-Access-Policy"
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

variable "root_volume_size" {
  description = "The size of the root volume in GB."
  type        = number
  default     = 25
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to use."
  type        = string
  default     = "ec2-mattermost-bucket"
}

variable "s3_bucket_policy_name" {
  description = "The name of the S3 bucket policy."
  type        = string
  default     = "mattermost-s3-bucket-policy"
}

variable "ssm_run_command_name" {
  description = "The name of the SSM document to run shell commands."
  type        = string
  default     = "MattermostDevDeployment"
}

variable "subnet_public_tag_name" {
  description = "[String]Default Subnet Tag Name"
  type        = string
  # default     = "mattermost-cloud-dev-shared-services-public-us-east-1a"
  default = "mattermost-cloud-dev-provisioning-102401280-private-1a"
}

variable "subnet_private_tag_name_1" {
  description = "[String]Default Subnet Tag Name"
  type        = string
  # default     = "mattermost-cloud-dev-shared-services-private-us-east-1a"
  default = "mattermost-cloud-dev-provisioning-102401280-private-1a"
}

variable "subnet_private_tag_name_2" {
  description = "[String]Default Subnet Tag Name"
  type        = string
  # default     = "mattermost-cloud-dev-shared-services-private-us-east-1b"
  default = "mattermost-cloud-dev-provisioning-102401280-private-1c"
}

variable "subnet_rds_private_tag_name" {
  description = "[String]Default Subnet Tag Name"
  type        = string
  default     = "mattermost-rds-subnet-group"
}

variable "vpc_tag_name" {
  description = "[String]Default VPC Tag Name"
  type        = string
  default     = "mattermost-cloud-dev-provisioning-102401280"
}



# Variables for Unique Naming in tfvars

variable "unique_name_suffix" {
  description = "A unique identifier for resource naming."
  type        = string
}

variable "unique_id" {
  description = "A unique ID for tagging and naming resources."
  type        = string
}

#####################################################################
#       These will be required variables without defaults           #
#####################################################################
variable "parameter_store_path_prefix" {
  description = "Prefix for SSM parameter names"
  type        = string
  default     = "/mattermost-dev-chris-self-hosted"
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

variable "domain_user_email" {
  description = "[String]Admin User Email Address for Forwarding"
  type        = string
}

variable "mattermost_db_username" {
  description = "The username for the RDS database admin user."
  type        = string
}

variable "mattermost_db_password" {
  description = "The password for the RDS database admin Password."
  type        = string
  sensitive   = true
}

variable "validation_method" {
  description = "Method to validate the certificate (DNS or EMAIL)"
  type        = string
  default     = "DNS"
}
#####################################################################
# End of variables.tf
