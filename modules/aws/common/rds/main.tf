
resource "aws_db_instance" "mattermost_rds" {
  depends_on = [
    aws_security_group.mattermost_rds_sg,
    aws_ssm_parameter.mattermost_db_username,
    aws_ssm_parameter.mattermost_db_password
  ]

  allocated_storage       = 20
  backup_retention_period = 7
  db_name                 = var.rds_db_name
  engine                  = var.rds_db_type
  identifier              = var.rds_db_name
  instance_class          = var.rds_instance_type
  parameter_group_name    = var.rds_db_version
  password                = aws_ssm_parameter.mattermost_db_password.value
  publicly_accessible     = false
  skip_final_snapshot     = true
  # storage_encrypted       = true
  username               = aws_ssm_parameter.mattermost_db_username.value
  vpc_security_group_ids = [aws_security_group.mattermost_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mattermost_db_subnets.name

  # attach IAM role for authentication
  iam_database_authentication_enabled = true

  kms_key_id = aws_kms_key.mattermost_rds_kms_key.arn




  tags = merge(
    { Name = var.rds_db_name },
    var.tags
  )
}

resource "aws_db_instance_role_association" "rds_s3_assoc" {
  db_instance_identifier = aws_db_instance.mattermost_rds.id
  feature_name           = "S3_INTEGRATION"
  role_arn               = aws_iam_role.mattermost_rds_role.arn
}
