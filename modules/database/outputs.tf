# Database Module Outputs

# RDS Instance Outputs
output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].id : null
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].arn : null
}

output "rds_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].endpoint : null
}

output "rds_instance_address" {
  description = "Address of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].address : null
}

output "rds_instance_port" {
  description = "Port of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].port : null
}

output "rds_instance_identifier" {
  description = "Identifier of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].identifier : null
}

output "rds_instance_resource_id" {
  description = "Resource ID of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.main[0].resource_id : null
}

# RDS Subnet Group Outputs
output "rds_subnet_group_id" {
  description = "ID of the RDS subnet group"
  value       = var.enable_rds ? aws_db_subnet_group.main[0].id : null
}

output "rds_subnet_group_arn" {
  description = "ARN of the RDS subnet group"
  value       = var.enable_rds ? aws_db_subnet_group.main[0].arn : null
}

output "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = var.enable_rds ? aws_db_subnet_group.main[0].name : null
}

# RDS Parameter Group Outputs
output "rds_parameter_group_id" {
  description = "ID of the RDS parameter group"
  value       = var.enable_rds ? aws_db_parameter_group.main[0].id : null
}

output "rds_parameter_group_arn" {
  description = "ARN of the RDS parameter group"
  value       = var.enable_rds ? aws_db_parameter_group.main[0].arn : null
}

output "rds_parameter_group_name" {
  description = "Name of the RDS parameter group"
  value       = var.enable_rds ? aws_db_parameter_group.main[0].name : null
}

# RDS Option Group Outputs
output "rds_option_group_id" {
  description = "ID of the RDS option group"
  value       = var.enable_rds ? aws_db_option_group.main[0].id : null
}

output "rds_option_group_arn" {
  description = "ARN of the RDS option group"
  value       = var.enable_rds ? aws_db_option_group.main[0].arn : null
}

output "rds_option_group_name" {
  description = "Name of the RDS option group"
  value       = var.enable_rds ? aws_db_option_group.main[0].name : null
}

# Read Replica Outputs
output "read_replica_id" {
  description = "ID of the read replica"
  value       = var.enable_rds && var.enable_read_replica ? aws_db_instance.read_replica[0].id : null
}

output "read_replica_arn" {
  description = "ARN of the read replica"
  value       = var.enable_rds && var.enable_read_replica ? aws_db_instance.read_replica[0].arn : null
}

output "read_replica_endpoint" {
  description = "Endpoint of the read replica"
  value       = var.enable_rds && var.enable_read_replica ? aws_db_instance.read_replica[0].endpoint : null
}

output "read_replica_address" {
  description = "Address of the read replica"
  value       = var.enable_rds && var.enable_read_replica ? aws_db_instance.read_replica[0].address : null
}

output "read_replica_port" {
  description = "Port of the read replica"
  value       = var.enable_rds && var.enable_read_replica ? aws_db_instance.read_replica[0].port : null
}

output "read_replica_identifier" {
  description = "Identifier of the read replica"
  value       = var.enable_rds && var.enable_read_replica ? aws_db_instance.read_replica[0].identifier : null
}

# CloudWatch Alarm Outputs
output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS CPU utilization alarm"
  value       = var.enable_rds && var.enable_monitoring ? aws_cloudwatch_metric_alarm.rds_cpu[0].arn : null
}

output "rds_free_storage_alarm_arn" {
  description = "ARN of the RDS free storage space alarm"
  value       = var.enable_rds && var.enable_monitoring ? aws_cloudwatch_metric_alarm.rds_free_storage[0].arn : null
}

output "rds_connections_alarm_arn" {
  description = "ARN of the RDS database connections alarm"
  value       = var.enable_rds && var.enable_monitoring ? aws_cloudwatch_metric_alarm.rds_connections[0].arn : null
}

output "read_replica_cpu_alarm_arn" {
  description = "ARN of the read replica CPU utilization alarm"
  value       = var.enable_rds && var.enable_read_replica && var.enable_monitoring ? aws_cloudwatch_metric_alarm.read_replica_cpu[0].arn : null
}

# Combined Database Outputs
output "all_rds_instance_ids" {
  description = "IDs of all RDS instances (main + read replica)"
  value = concat(
    var.enable_rds ? [aws_db_instance.main[0].id] : [],
    var.enable_rds && var.enable_read_replica ? [aws_db_instance.read_replica[0].id] : []
  )
}

output "all_rds_endpoints" {
  description = "Endpoints of all RDS instances"
  value = concat(
    var.enable_rds ? [aws_db_instance.main[0].endpoint] : [],
    var.enable_rds && var.enable_read_replica ? [aws_db_instance.read_replica[0].endpoint] : []
  )
}

output "all_cloudwatch_alarm_arns" {
  description = "ARNs of all CloudWatch alarms"
  value = concat(
    var.enable_rds && var.enable_monitoring ? [aws_cloudwatch_metric_alarm.rds_cpu[0].arn] : [],
    var.enable_rds && var.enable_monitoring ? [aws_cloudwatch_metric_alarm.rds_free_storage[0].arn] : [],
    var.enable_rds && var.enable_monitoring ? [aws_cloudwatch_metric_alarm.rds_connections[0].arn] : [],
    var.enable_rds && var.enable_read_replica && var.enable_monitoring ? [aws_cloudwatch_metric_alarm.read_replica_cpu[0].arn] : []
  )
}