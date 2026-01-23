
resource "aws_db_subnet_group" "mattermost_db_subnets" {
  name = var.subnet_rds_private_tag_name
  subnet_ids = [
    data.aws_subnet.private_mattermost_subnet_1.id,
    data.aws_subnet.private_mattermost_subnet_2.id
  ]

  tags = merge(
    { Name = var.subnet_rds_private_tag_name },
    var.tags
  )
}
