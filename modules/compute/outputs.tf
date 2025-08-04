# Compute Module Outputs

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].private_ip : null
}

output "bastion_public_dns" {
  description = "Public DNS of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_dns : null
}

# Application Server Outputs
output "app_server_instance_ids" {
  description = "IDs of the application server instances"
  value       = var.enable_app_server ? aws_instance.app_server[*].id : []
}

output "app_server_private_ips" {
  description = "Private IPs of the application server instances"
  value       = var.enable_app_server ? aws_instance.app_server[*].private_ip : []
}

output "app_server_public_ips" {
  description = "Public IPs of the application server instances"
  value       = var.enable_app_server ? aws_instance.app_server[*].public_ip : []
}

# Auto Scaling Group Outputs
output "asg_name" {
  description = "Name of the auto scaling group"
  value       = var.enable_auto_scaling_group ? aws_autoscaling_group.app[0].name : null
}

output "asg_arn" {
  description = "ARN of the auto scaling group"
  value       = var.enable_auto_scaling_group ? aws_autoscaling_group.app[0].arn : null
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = var.enable_auto_scaling_group ? aws_launch_template.app[0].id : null
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = var.enable_auto_scaling_group ? aws_launch_template.app[0].arn : null
}

# Auto Scaling Policy Outputs
output "cpu_scaling_policy_arn" {
  description = "ARN of the CPU scaling policy"
  value       = var.enable_auto_scaling_group && var.enable_cpu_scaling ? aws_autoscaling_policy.cpu[0].arn : null
}

# CloudWatch Alarm Outputs
output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = var.enable_auto_scaling_group && var.enable_cpu_scaling ? aws_cloudwatch_metric_alarm.cpu[0].arn : null
}

# Combined Outputs
output "all_instance_ids" {
  description = "IDs of all EC2 instances (bastion + app servers)"
  value = concat(
    var.enable_bastion ? [aws_instance.bastion[0].id] : [],
    var.enable_app_server ? aws_instance.app_server[*].id : []
  )
}

output "all_private_ips" {
  description = "Private IPs of all EC2 instances"
  value = concat(
    var.enable_bastion ? [aws_instance.bastion[0].private_ip] : [],
    var.enable_app_server ? aws_instance.app_server[*].private_ip : []
  )
}