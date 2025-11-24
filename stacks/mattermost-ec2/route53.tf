
# resource "aws_eip" "mattermost_eip" {
#   depends_on = [aws_instance.ami_instance_mattermost_ec2_spot]

#   instance = aws_instance.ami_instance_mattermost_ec2_spot.id
#   tags = {
#     Name = "Mattermost EIP"
#   }
# }


data "aws_route53_zone" "parent" {
  name         = local.base_domain # must end with a dot
  private_zone = false             # true if this is a private hosted zone
}

output "route53_zone_info" {
  value = {
    id           = data.aws_route53_zone.parent.id
    name         = data.aws_route53_zone.parent.name
    private_zone = data.aws_route53_zone.parent.private_zone
    comment      = data.aws_route53_zone.parent.comment
    name_servers = data.aws_route53_zone.parent.name_servers
  }
}

resource "aws_route53_record" "mattermost" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = local.domain
  type    = "A"
  ttl     = 60
  records = [aws_instance.ami_instance_mattermost_ec2_spot.private_ip]
}
