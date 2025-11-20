

###############################################
# EC2 Outputs
###############################################
output "mattermost_ami_type" {
  value = data.aws_ami.ami_type.id
}

output "mattermost_ec2_id" {
  value = aws_instance.ami_instance_mattermost_ec2_spot.id
}

output "mattermost_ec2_name" {
  value = local.ec2_instance_name
}

output "mattermost_ec2_public_ip" {
  value = aws_instance.ami_instance_mattermost_ec2_spot.public_ip
}

output "mattermost_iam_role_name" {
  value = aws_iam_role.mattermost_ec2_role.name
}

output "mattermost_s3_bucket" {
  value = aws_s3_bucket.mattermost_bucket.id
}

###############################################
# RDS Outputs
###############################################
output "mattermost_rds_endpoint" {
  value = aws_db_instance.mattermost_rds.endpoint
}

output "mattermost_rds_id" {
  value = aws_db_instance.mattermost_rds.id
}

output "mattermost_rds_port" {
  value = aws_db_instance.mattermost_rds.port
}

###############################################
# Extra Data
###############################################
output "domain" {
  value = local.domain
}

output "deployment_date" {
  value = time_static.deployment_date.rfc3339
}
###############################################
# End of outputs.tf
###############################################
