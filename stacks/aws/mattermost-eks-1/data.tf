
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_ami" "ami_type" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["${var.ami_type}"]
  }
}

# S3 Policy for EC2 Access to bucket
data "aws_iam_policy_document" "mattermost_s3_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.mattermost_bucket.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.mattermost_bucket.arn}/*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
      "sts:AssumeRole",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:CreateListener",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "elasticloadbalancing:*",
      "ec2:Describe*",
      "ec2:CreateNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Assume EC2 Role Trust Relationship
data "aws_iam_policy_document" "assume_eks" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.mattermost_app_namespace}:${var.mattermost_app_service_account_name}"]
    }

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}"]
    }
  }
}

# RDS Policy for EC2 to Access the Database
data "aws_iam_policy_document" "mattermost_rds_policy" {
  statement {
    actions = [
      "rds-db:connect",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [
      # RDS DB user ARN format: arn:aws:rds-db:region:account-id:dbuser:dbi-resource-id/db-username
      "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.mattermost_rds.resource_id}/${aws_db_instance.mattermost_rds.username}",
      aws_ssm_parameter.mattermost_db_username.arn,
      aws_ssm_parameter.mattermost_db_password.arn
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "mattermost_rds_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        module.rds_db_mattermost.mattermost_rds_role_arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}"
      ]
    }
    effect = "Allow"
  }
}

data "aws_vpc" "mattermost_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_tag_name]
  }
}

# EKS Public Subnet Data Calls

data "aws_subnet" "public_mattermost_subnet_1" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_public_tag_name_1]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mattermost_vpc.id]
  }
}

data "aws_subnet" "public_mattermost_subnet_2" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_public_tag_name_2]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mattermost_vpc.id]
  }
}

## RDS Subnet Group Data Calls
data "aws_subnet" "private_mattermost_subnet_1" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_private_tag_name_1]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mattermost_vpc.id]
  }
}

data "aws_subnet" "private_mattermost_subnet_2" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_private_tag_name_2]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.mattermost_vpc.id]
  }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}


## Cluster EKS Data Calls
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.mattermost_eks_cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.mattermost_eks_cluster.name
}
