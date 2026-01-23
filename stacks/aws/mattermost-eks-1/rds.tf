

###############################################
# RDS Placeholder
###############################################

module "rds_db_mattermost" {
  source = "../../../modules/aws/common/rds"

  rds_security_group_name          = local.rds_security_group_name
  vpc_id                           = var.vpc_id
  mattermost_eks_security_group_id = var.mattermost_eks_security_group_id
  tags                             = local.tags
  subnet_rds_private_tag_name      = local.subnet_rds_private_tag_name
  rds_db_name                      = local.rds_db_name
  rds_db_type                      = var.rds_db_type
  rds_instance_type                = var.rds_instance_type
  rds_db_version                   = var.rds_db_version
  rds_db_policy_name               = local.rds_db_policy_name
  mattermost_db_username           = var.mattermost_db_username
  mattermost_db_password           = var.mattermost_db_password
  mattermost_rds_role_name         = local.mattermost_rds_role_name
  parameter_store_path_prefix      = local.parameter_store_path_prefix
  assume_role_policy_json          = data.aws_iam_policy_document.mattermost_rds_assume_role_policy.json
  mattermost_rds_policy_json       = data.aws_iam_policy_document.mattermost_rds_policy.json
  kms_deletion_window_in_days      = var.kms_deletion_window_in_days
  kms_key_policy_json              = local.kms_key_policy_json
  rds_kms_alias_name               = local.rds_kms_alias_name
  rds_db_identifier                = local.rds_db_identifier
}
