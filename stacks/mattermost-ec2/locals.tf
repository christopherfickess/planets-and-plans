locals {
  base_identifier = "${var.unique_name_suffix}-mattermost-${var.unique_id}"

  domain                    = "chat.dev.${var.unique_name_suffix}.com"
  ec2_instance_name         = "${var.ec2_instance_name}-${local.base_identifier}"
  ec2_instance_profile_name = "${var.ec2_instance_profile_name}-${local.base_identifier}"
  ec2_security_group_name   = "${var.ec2_security_group_name}-${local.base_identifier}"
  ec2_iam_role_name         = "${var.ec2_iam_role_name}-${local.base_identifier}"
  ec2_iam_role_policy_name  = "${var.ec2_iam_role_policy_name}-${local.base_identifier}"
  rds_db_name               = "${var.rds_db_name}-${local.base_identifier}"
  rds_db_policy_name        = "${var.rds_db_policy_name}-${local.base_identifier}"
  rds_security_group_name   = "${var.rds_security_group_name}-${local.base_identifier}"
  s3_bucket_name            = "${var.s3_bucket_name}-${local.base_identifier}"
  s3_bucket_policy_name     = "${var.s3_bucket_policy_name}-${local.base_identifier}"


  tags = {
    Name   = "dev-mattermost-ec2-spot-instance-chris-fickess"
    Type   = "Testing"
    Date   = time_static.deployment_date.rfc3339
    Domain = local.domain
  }
}
