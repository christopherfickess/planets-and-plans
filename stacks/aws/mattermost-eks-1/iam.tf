###############################################
# IAM Role + Policy
###############################################
resource "aws_iam_role" "mattermost_eks_cluster_role" {
  name = local.eks_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.mattermost_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS NG Role + Policy

resource "aws_iam_role" "mattermost_eks_node_role" {
  depends_on = [aws_eks_cluster.mattermost_eks_cluster]

  name               = local.eks_node_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_eks.json

  tags = merge(
    { Name = local.eks_node_role_name },
    local.tags
  )
}

# EKS NG Policy
resource "aws_iam_policy" "mattermost_eks_node_policy" {

  name        = local.eks_iam_role_policy_name
  description = "IAM policy to allow Mattermost EC2 instances to access Mattermost S3 bucket"
  policy      = data.aws_iam_policy_document.mattermost_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachments" {
  count = length(local.eks_role_policy_attachment_names)

  role       = aws_iam_role.mattermost_eks_cluster_role.name
  policy_arn = local.eks_role_policy_attachment_names[count.index]
}

resource "aws_iam_role_policy_attachment" "eks_node_sa_role_policy_attachments" {
  depends_on = [aws_iam_policy.mattermost_eks_node_policy]

  role       = aws_iam_role.mattermost_eks_node_role.name
  policy_arn = aws_iam_policy.mattermost_eks_node_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_cluster_ng_policy_attachments" {
  count = length(local.eks_ng_policy_attachment_names)

  role       = aws_iam_role.mattermost_eks_node_role.name
  policy_arn = local.eks_ng_policy_attachment_names[count.index]
}
