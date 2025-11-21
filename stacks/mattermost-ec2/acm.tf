


# resource "aws_acm_certificate" "mattermost_cert" {
#   domain_name       = local.domain
#   validation_method = var.validation_method

#   tags = merge({
#     Name = local.domain },
#     local.tags
#   )
# }

# resource "aws_route53_record" "cert_validation" {
#   depends_on = [
#     aws_acm_certificate.mattermost_cert,
#     aws_route53_record.mattermost
#   ]
#   for_each = { for dvo in aws_acm_certificate.mattermost_cert.domain_validation_options : dvo.domain_name => dvo }

#   name    = each.value.resource_record_name
#   type    = each.value.resource_record_type
#   zone_id = aws_route53_record.mattermost.zone_id
#   ttl     = 60
#   records = [each.value.resource_record_value]
# }


# resource "aws_acm_certificate_validation" "mattermost_cert_validation" {
#   depends_on = [
#     aws_acm_certificate.mattermost_cert,
#     aws_route53_record.mattermost
#   ]

#   certificate_arn         = aws_acm_certificate.mattermost_cert.arn
#   validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
# }

