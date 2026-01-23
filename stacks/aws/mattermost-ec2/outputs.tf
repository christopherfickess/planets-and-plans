#################################################
#                  EC2 Outputs                  
#################################################

output "mattermost_ec2_info" {
  value = {
    ami_type  = data.aws_ami.ami_type.id
    ec2_id    = aws_instance.ami_instance_mattermost_ec2_spot.id
    ec2_name  = local.ec2_instance_name
    public_ip = aws_instance.ami_instance_mattermost_ec2_spot.public_ip
    iam_role  = aws_iam_role.mattermost_ec2_role.name
    s3_bucket = aws_s3_bucket.mattermost_bucket.id
  }
}


#################################################
#                  RDS Outputs                  
#################################################

output "mattermost_rds_info" {
  value = {
    endpoint = aws_db_instance.mattermost_rds.endpoint
    id       = aws_db_instance.mattermost_rds.id
    port     = aws_db_instance.mattermost_rds.port
  }
}


#################################################
#                Route53 Outputs                
#################################################

output "route53_zone_info" {
  value = {
    name = data.aws_route53_zone.parent.name
  }
}


#################################################
#                Auxiliary Outputs              
#################################################

output "deployment_info" {
  value = {
    deployment_date = time_static.deployment_date.rfc3339
    domain          = local.domain
    my_public_ip    = trimspace(data.http.my_ip.response_body)
  }
}


#################################################
#                  End of File                  
#################################################
