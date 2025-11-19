

###############################################
# EC2 Outputs
###############################################
output "ami_type" {
  value = data.aws_ami.ami_type.id
}

output "ec2_public_ip" {
  value = aws_instance.ami_instance_mattermost_ec2_spot.public_ip
}

output "ec2_id" {
  value = aws_instance.ami_instance_mattermost_ec2_spot.id
}

output "s3_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "iam_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "name" {
  value = local.ec2_instance_name
}

###############################################
# RDS Outputs
###############################################
output "rds_endpoint" {
  value = aws_db_instance.mattermost_rds.endpoint
}

output "rds_id" {
  value = aws_db_instance.mattermost_rds.id
}

output "rds_port" {
  value = aws_db_instance.mattermost_rds.port
}

###############################################
# End of outputs.tf
###############################################
