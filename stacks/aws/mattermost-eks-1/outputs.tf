#################################################
#                  EC2 Outputs                  
#################################################
output "mattermost_eks_info" {
  value = {
    cluster_name = local.eks_cluster_name
    iam_role     = aws_iam_role.mattermost_eks_cluster_role.name
    s3_bucket    = aws_s3_bucket.mattermost_bucket.id
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
