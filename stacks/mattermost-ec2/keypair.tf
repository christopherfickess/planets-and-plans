
# Use this if you want terraform to do the whole piece for ssh
# resource "tls_private_key" "mattermost_key" {
#   algorithm = "ED25519"
# }

# resource "aws_key_pair" "mattermost_key_pair" {
#   key_name   = "mattermost-ed25519-${local.base_identifier}"
#   public_key = tls_private_key.mattermost_key.public_key_openssh
# }

# output "mattermost_private_key" {
#   value     = tls_private_key.mattermost_key.private_key_pem
#   sensitive = true
# }

resource "aws_key_pair" "mattermost_key_pair" {
  key_name   = local.key_pair_name
  public_key = file("~/.ssh/test-mm-client-ec2.pub")
}
