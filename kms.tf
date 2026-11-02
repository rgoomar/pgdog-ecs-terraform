# ------------------------------------------------------------------------------
# KMS access for secret injection
# ECS reads secrets with the task execution role. Secrets encrypted with a
# customer managed key need kms:Decrypt on that key.
# ------------------------------------------------------------------------------

locals {
  decrypt_kms_key_arns = distinct(compact(concat(
    [var.secrets_kms_key_arn],
    var.additional_kms_key_arns
  )))
}

resource "aws_iam_role_policy" "task_execution_kms" {
  count = var.create_resources && length(local.decrypt_kms_key_arns) > 0 ? 1 : 0

  name = "${var.name}-pgdog-execution-kms"
  role = aws_iam_role.task_execution[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = local.decrypt_kms_key_arns
      }
    ]
  })
}
