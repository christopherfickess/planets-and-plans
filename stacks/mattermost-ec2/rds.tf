

###############################################
# RDS Placeholder
###############################################

resource "aws_db_instance" "mattermost_rds" {
  depends_on = [
    aws_security_group.mattermost_rds_sg,
    aws_ssm_parameter.mattermost_db_username,
    aws_ssm_parameter.mattermost_db_password
  ]

  allocated_storage       = 20
  backup_retention_period = 7
  db_name                 = local.rds_db_name
  engine                  = "postgres"
  identifier              = "mattermost-db"
  instance_class          = var.rds_instance_type
  parameter_group_name    = "default.postgres12"
  password                = aws_ssm_parameter.mattermost_db_password.name
  publicly_accessible     = false
  skip_final_snapshot     = true
  # storage_encrypted       = true
  username               = aws_ssm_parameter.mattermost_db_username.name
  vpc_security_group_ids = [aws_security_group.mattermost_rds_sg.id]

  tags = merge(
    { Name = local.rds_db_name },
    local.tags
  )
}
