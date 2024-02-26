resource "aws_cloudwatch_log_group" "logs_group" {
  name = var.logs_group
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization" {
  alarm_name          = "ecs-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Alarm when CPU exceeds 70%"
  alarm_actions       = ["arn:aws:sns:us-east-1:030741324211:deleteec2notification"] # Update with your SNS topic ARN

  dimensions = {
    ClusterName = aws_ecs_cluster.my_cluster.name
  }
}

