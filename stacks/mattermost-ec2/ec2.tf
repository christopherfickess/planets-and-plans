
resource "aws_iam_instance_profile" "mattermost_ec2_profile" {
  depends_on = [aws_iam_role.mattermost_ec2_role]

  name = local.ec2_instance_profile_name
  role = aws_iam_role.mattermost_ec2_role.name
}

resource "aws_instance" "ami_instance_mattermost_ec2_spot" {
  depends_on = [
    data.aws_ami.ami_type,
    aws_iam_instance_profile.mattermost_ec2_profile,
    aws_ssm_parameter.mattermost_db_username,
    aws_ssm_parameter.mattermost_db_password,
    aws_security_group.mattermost_ec2_sg
  ]

  ami                  = data.aws_ami.ami_type.id
  iam_instance_profile = aws_iam_instance_profile.mattermost_ec2_profile.name

  security_groups = [
    aws_security_group.mattermost_ec2_sg.name
  ]

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = 0.0031
    }
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
    # kms_key_id  = aws_kms_key.ec2_kms.arn
  }

  instance_type = var.ec2_instance_size

  # Only needed if not using AL2023 AMI (need ssm agent)
  user_data = templatefile("${path.module}/scripts/mattermost_cloud_init.yaml", {
    mattermost_email   = var.domain_user_email
    mattermost_domain  = local.domain
    mattermost_version = var.mattermost_version
    password_param     = aws_ssm_parameter.mattermost_db_password.name
    rds_endpoint       = aws_db_instance.mattermost_rds.address
    username_param     = aws_ssm_parameter.mattermost_db_username.name
  })

  tags = local.tags
}

