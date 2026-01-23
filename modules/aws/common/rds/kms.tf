
resource "aws_kms_key" "mattermost_rds_kms_key" {
  description             = "KMS key for Mattermost RDS instance"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = var.kms_key_policy_json

  tags = merge(
    { Name = "${var.rds_db_name}-kms-key" },
    var.tags
  )
}

resource "aws_kms_alias" "mattermost_rds_kms_alias" {
  name          = "alias/${var.rds_kms_alias_name}"
  target_key_id = aws_kms_key.mattermost_rds_kms_key.key_id
}
