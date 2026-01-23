
resource "aws_security_group" "mattermost_rds_sg" {
  name        = var.rds_security_group_name
  description = "Security group for Mattermost RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(
    { Name = var.rds_security_group_name },
    var.tags
  )
}

resource "aws_security_group_rule" "allow_mattermost_eks_to_rds" {
  description              = "Allow Mattermost EKS cluster to connect to RDS"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mattermost_rds_sg.id
  source_security_group_id = var.mattermost_eks_security_group_id
}
