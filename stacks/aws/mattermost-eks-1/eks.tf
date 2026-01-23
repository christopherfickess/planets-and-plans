
resource "aws_eks_cluster" "mattermost_eks_cluster" {
  depends_on = [
    # aws_iam_role.mattermost_eks_cluster_role,
    aws_iam_policy.mattermost_eks_node_policy
  ]

  name     = local.eks_cluster_name
  role_arn = aws_iam_role.mattermost_eks_cluster_role.arn
  version  = var.eks_cluster_version

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = concat(
      [data.aws_subnet.private_mattermost_subnet_1.id],
      [data.aws_subnet.private_mattermost_subnet_2.id],
    )
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

resource "aws_eks_node_group" "mattermost_eks_node_group" {
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_ng_policy_attachments]

  cluster_name    = aws_eks_cluster.mattermost_eks_cluster.name
  node_group_name = local.eks_node_group_name
  node_role_arn   = aws_iam_role.mattermost_eks_node_role.arn

  ami_type = "AL2023_x86_64_STANDARD" # <-- Move to aws_launch_template later with data call?

  subnet_ids = [
    data.aws_subnet.private_mattermost_subnet_1.id,
    data.aws_subnet.private_mattermost_subnet_2.id
  ]

  scaling_config {
    desired_size = var.eks_node_desired_capacity
    max_size     = var.eks_node_max_capacity
    min_size     = var.eks_node_min_capacity
  }

  instance_types = [var.eks_node_instance_type]
}


