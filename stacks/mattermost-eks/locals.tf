locals {
  base_identifier = "${var.unique_name_suffix}-mattermost-${var.unique_id}"

  base_domain                     = "dev.cloud.mattermost.com"
  domain                          = "chris-fickess.${local.base_domain}"
  eks_cluster_name                = "mattermost-eks-${local.base_identifier}"
  eks_cluster_security_group_name = "${var.eks_cluster_security_group_name}-${local.base_identifier}"
  eks_node_group_name             = "mattermost-eks-node-group-${local.base_identifier}"
  eks_node_role_name              = "eks-node-role-${local.base_identifier}"
  eks_iam_role_name               = "${var.eks_iam_role_name}-${local.base_identifier}"
  eks_iam_role_policy_name        = "${var.eks_iam_role_policy_name}-${local.base_identifier}"
  key_pair_name                   = "${var.key_pair_name}-${local.base_identifier}"
  kms_mattermost_kms_key_alias    = "${var.mattermost_kms_key_alias}-${local.base_identifier}"
  rds_db_name                     = "${var.rds_db_identifier}-${local.base_identifier}"
  subnet_rds_private_tag_name     = "${var.subnet_rds_private_tag_name}-${local.base_identifier}"
  rds_db_policy_name              = "${var.rds_db_policy_name}-${local.base_identifier}"
  rds_security_group_name         = "${var.rds_security_group_name}-${local.base_identifier}"
  s3_bucket_name                  = "${var.s3_bucket_name}-${local.base_identifier}"
  s3_bucket_policy_name           = "${var.s3_bucket_policy_name}-${local.base_identifier}"


  tags = {
    Type   = "Testing"
    Date   = time_static.deployment_date.rfc3339
    Domain = local.domain
  }
}
