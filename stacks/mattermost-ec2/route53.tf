
resource "aws_eip" "mattermost_eip" {
  depends_on = [aws_instance.ami_instance_mattermost_ec2_spot]

  instance = aws_instance.ami_instance_mattermost_ec2_spot.id
  tags = {
    Name = "Mattermost EIP"
  }
}


resource "aws_route53_record" "mattermost" {
  zone_id = local.base_domain # e.g., hosted zone ID for chris-fickess.mattermost.com
  name    = local.domain      # e.g., hosted zone ID for chat.dev.chris-fickess.mattermost.com
  type    = "A"
  ttl     = 300
  records = [aws_eip.mattermost_eip.public_ip]
}
