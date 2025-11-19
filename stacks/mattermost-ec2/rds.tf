

###############################################
# RDS Placeholder
###############################################

resource "aws_db_instance" "mattermost_rds" {
  depends_on = [aws_security_group.rds_sg]

  allocated_storage       = 20
  backup_retention_period = 7
  db_name                 = local.rds_db_name
  engine                  = "postgres"
  identifier              = "mattermost-db"
  instance_class          = var.rds_instance_type
  parameter_group_name    = "default.postgres12"
  password                = var.db_password
  publicly_accessible     = false
  skip_final_snapshot     = true
  # storage_encrypted       = true
  username               = var.db_username
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
