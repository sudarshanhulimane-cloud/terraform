# Load Balancer Module Outputs

# Application Load Balancer Outputs
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].id : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].zone_id : null
}

# Target Group Outputs
output "target_group_http_arn" {
  description = "ARN of the HTTP target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.http[0].arn : null
}

output "target_group_http_id" {
  description = "ID of the HTTP target group"
  value       = var.enable_load_balancer ? aws_lb_target_group.http[0].id : null
}

output "target_group_https_arn" {
  description = "ARN of the HTTPS target group"
  value       = var.enable_load_balancer && var.enable_https ? aws_lb_target_group.https[0].arn : null
}

output "target_group_https_id" {
  description = "ID of the HTTPS target group"
  value       = var.enable_load_balancer && var.enable_https ? aws_lb_target_group.https[0].id : null
}

# Listener Outputs
output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = var.enable_load_balancer ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.enable_load_balancer && var.enable_https ? aws_lb_listener.https[0].arn : null
}

# Combined Target Group Outputs
output "target_group_arns" {
  description = "List of target group ARNs"
  value = var.enable_load_balancer ? (
    var.enable_https ? [aws_lb_target_group.http[0].arn, aws_lb_target_group.https[0].arn] : [aws_lb_target_group.http[0].arn]
  ) : []
}

output "target_group_ids" {
  description = "List of target group IDs"
  value = var.enable_load_balancer ? (
    var.enable_https ? [aws_lb_target_group.http[0].id, aws_lb_target_group.https[0].id] : [aws_lb_target_group.http[0].id]
  ) : []
}

# CloudWatch Alarm Outputs
output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5XX errors alarm"
  value       = var.enable_load_balancer && var.enable_monitoring ? aws_cloudwatch_metric_alarm.alb_5xx[0].arn : null
}

output "alb_target_5xx_alarm_arn" {
  description = "ARN of the ALB target 5XX errors alarm"
  value       = var.enable_load_balancer && var.enable_monitoring ? aws_cloudwatch_metric_alarm.alb_target_5xx[0].arn : null
}

output "alb_response_time_alarm_arn" {
  description = "ARN of the ALB response time alarm"
  value       = var.enable_load_balancer && var.enable_monitoring ? aws_cloudwatch_metric_alarm.alb_response_time[0].arn : null
}

# Load Balancer URL Outputs
output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = var.enable_load_balancer ? "http://${aws_lb.main[0].dns_name}" : null
}

output "alb_https_url" {
  description = "HTTPS URL of the Application Load Balancer"
  value       = var.enable_load_balancer && var.enable_https ? "https://${aws_lb.main[0].dns_name}" : null
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  value       = var.enable_load_balancer ? aws_lb.main[0].security_groups[0] : null
}