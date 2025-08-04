# Monitoring Module Outputs

output "log_group_names" {
  description = "Names of CloudWatch log groups"
  value = [
    aws_cloudwatch_log_group.bastion.name,
    aws_cloudwatch_log_group.app.name,
    aws_cloudwatch_log_group.nginx.name,
    aws_cloudwatch_log_group.eks_nodes.name,
    aws_cloudwatch_log_group.eks_pods.name
  ]
}

output "alarm_names" {
  description = "Names of CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.bastion_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.bastion_status.alarm_name,
    aws_cloudwatch_metric_alarm.asg_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.eks_node_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.eks_node_memory.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.rds_connections.alarm_name,
    aws_cloudwatch_metric_alarm.rds_free_storage.alarm_name,
    aws_cloudwatch_metric_alarm.alb_target_response_time.alarm_name,
    aws_cloudwatch_metric_alarm.alb_unhealthy_targets.alarm_name
  ]
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].arn : null
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}