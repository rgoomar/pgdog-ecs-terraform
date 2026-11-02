# ------------------------------------------------------------------------------
# CloudWatch Alarms (optional)
# ------------------------------------------------------------------------------

locals {
  create_alarms = var.create_resources && var.create_alarms
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count = local.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-pgdog-unhealthy-hosts"
  alarm_description   = "PgDog targets are failing NLB health checks"
  namespace           = "AWS/NetworkELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  period              = 60
  evaluation_periods  = 3
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.pgdog[0].arn_suffix
    TargetGroup  = aws_lb_target_group.pgdog[0].arn_suffix
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "healthy_hosts_low" {
  count = local.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-pgdog-healthy-hosts-low"
  alarm_description   = "Fewer healthy PgDog targets than min_capacity"
  namespace           = "AWS/NetworkELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  comparison_operator = "LessThanThreshold"
  threshold           = var.min_capacity
  period              = 60
  evaluation_periods  = 3
  treat_missing_data  = "breaching"

  dimensions = {
    LoadBalancer = aws_lb.pgdog[0].arn_suffix
    TargetGroup  = aws_lb_target_group.pgdog[0].arn_suffix
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = local.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-pgdog-cpu-high"
  alarm_description   = "PgDog service CPU is high. Autoscaling may be at max_capacity."
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alarm_cpu_threshold
  period              = 60
  evaluation_periods  = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = aws_ecs_service.pgdog[0].name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
  tags          = var.tags
}
