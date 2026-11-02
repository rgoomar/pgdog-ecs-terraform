# ------------------------------------------------------------------------------
# CloudWatch Log Group
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "pgdog" {
  count = var.create_resources ? 1 : 0

  name              = "/ecs/${var.name}-pgdog"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# The ADOT sidecar writes metrics here (EMF format). Managing it in Terraform sets a
# retention period; otherwise the sidecar creates it with no expiry.
resource "aws_cloudwatch_log_group" "metrics" {
  count = var.create_resources && var.export_metrics_to_cloudwatch ? 1 : 0

  name              = "/aws/ecs/${var.name}-pgdog/metrics"
  retention_in_days = coalesce(var.metrics_log_retention_days, var.log_retention_days)

  tags = var.tags
}
