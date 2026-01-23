

###############################################
# RDS Placeholder
###############################################
resource "aws_db_subnet_group" "mattermost_db_subnets" {
  name = local.subnet_rds_private_tag_name
  subnet_ids = [
    data.aws_subnet.private_mattermost_subnet_1.id,
    data.aws_subnet.private_mattermost_subnet_2.id
  ]

  tags = merge(
    { Name = local.subnet_rds_private_tag_name },
    local.tags
  )
}

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
  identifier              = local.rds_db_name
  instance_class          = var.rds_instance_type
  parameter_group_name    = var.rds_db_version
  password                = aws_ssm_parameter.mattermost_db_password.value
  publicly_accessible     = false
  skip_final_snapshot     = true
  # storage_encrypted       = true
  username               = aws_ssm_parameter.mattermost_db_username.value
  vpc_security_group_ids = [aws_security_group.mattermost_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mattermost_db_subnets.name


  tags = merge(
    { Name = var.rds_db_name },
    local.tags
  )
}
