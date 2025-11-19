
resource "aws_iam_instance_profile" "ec2_profile" {
  depends_on = [aws_iam_role.ec2_role]

  name = local.ec2_instance_profile_name
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "ami_instance_mattermost_ec2_spot" {
  depends_on = [data.aws_ami.ami_type, aws_iam_instance_profile.ec2_profile]

  ami                  = data.aws_ami.ami_type.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

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
  # user_data = file("${path.module}/user_data/mattermost-ec2-user-data.sh")

  tags = {
    Name = "test-mattermost-ec2-spot-instance-chris-fickess"
  }
}

