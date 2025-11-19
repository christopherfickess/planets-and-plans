resource "aws_ssm_document" "run_shell_command" {
  depends_on = [aws_iam_role.ec2_role]

  name          = var.ssm_run_command_name
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Run shell command on EC2"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "runShellScript"
        inputs = {
          runCommand = file("${path.module}/scripts/setup_mattermost_ec2.yaml")
        }
      }
    ]
  })
}
