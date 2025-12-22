
resource "aws_eks_access_entry" "mattermost_eks_access_entry" {
  cluster_name  = aws_eks_cluster.mattermost_eks_cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_name}"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "mattermost_admin_association" {
  cluster_name  = aws_eks_cluster.mattermost_eks_cluster.name
  principal_arn = aws_eks_access_entry.mattermost_eks_access_entry.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
