# Storage Module Outputs

# S3 Bucket Outputs
output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.enable_s3_bucket ? aws_s3_bucket.app_data[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.enable_s3_bucket ? aws_s3_bucket.app_data[0].arn : null
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = var.enable_s3_bucket ? aws_s3_bucket.app_data[0].bucket : null
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = var.enable_s3_bucket ? aws_s3_bucket.app_data[0].region : null
}

# Access Logs S3 Bucket Outputs
output "access_logs_bucket_id" {
  description = "ID of the access logs S3 bucket"
  value       = var.enable_access_logs_bucket ? aws_s3_bucket.access_logs[0].id : null
}

output "access_logs_bucket_arn" {
  description = "ARN of the access logs S3 bucket"
  value       = var.enable_access_logs_bucket ? aws_s3_bucket.access_logs[0].arn : null
}

output "access_logs_bucket_name" {
  description = "Name of the access logs S3 bucket"
  value       = var.enable_access_logs_bucket ? aws_s3_bucket.access_logs[0].bucket : null
}

# EBS Volume Outputs
output "ebs_volume_ids" {
  description = "IDs of the EBS volumes"
  value       = var.enable_ebs_volume ? aws_ebs_volume.app_data[*].id : []
}

output "ebs_volume_arns" {
  description = "ARNs of the EBS volumes"
  value       = var.enable_ebs_volume ? aws_ebs_volume.app_data[*].arn : []
}

output "ebs_volume_sizes" {
  description = "Sizes of the EBS volumes in GB"
  value       = var.enable_ebs_volume ? aws_ebs_volume.app_data[*].size : []
}

output "ebs_volume_types" {
  description = "Types of the EBS volumes"
  value       = var.enable_ebs_volume ? aws_ebs_volume.app_data[*].type : []
}

output "ebs_volume_availability_zones" {
  description = "Availability zones of the EBS volumes"
  value       = var.enable_ebs_volume ? aws_ebs_volume.app_data[*].availability_zone : []
}

# EBS Volume Attachment Outputs
output "ebs_volume_attachment_ids" {
  description = "IDs of the EBS volume attachments"
  value       = var.enable_ebs_volume && var.attach_ebs_volume ? aws_volume_attachment.app_data[*].id : []
}

output "ebs_volume_attachment_device_names" {
  description = "Device names of the EBS volume attachments"
  value       = var.enable_ebs_volume && var.attach_ebs_volume ? aws_volume_attachment.app_data[*].device_name : []
}

output "ebs_volume_attachment_instance_ids" {
  description = "Instance IDs of the EBS volume attachments"
  value       = var.enable_ebs_volume && var.attach_ebs_volume ? aws_volume_attachment.app_data[*].instance_id : []
}

# EBS Snapshot Outputs
output "ebs_snapshot_ids" {
  description = "IDs of the EBS snapshots"
  value       = var.enable_ebs_snapshot ? aws_ebs_snapshot.app_data[*].id : []
}

output "ebs_snapshot_arns" {
  description = "ARNs of the EBS snapshots"
  value       = var.enable_ebs_snapshot ? aws_ebs_snapshot.app_data[*].arn : []
}

# CloudWatch Alarm Outputs
output "s3_bucket_size_alarm_arn" {
  description = "ARN of the S3 bucket size alarm"
  value       = var.enable_s3_bucket && var.enable_monitoring ? aws_cloudwatch_metric_alarm.s3_bucket_size[0].arn : null
}

output "ebs_volume_usage_alarm_arns" {
  description = "ARNs of the EBS volume usage alarms"
  value       = var.enable_ebs_volume && var.enable_monitoring ? aws_cloudwatch_metric_alarm.ebs_volume_usage[*].arn : []
}

# Combined Storage Outputs
output "all_s3_bucket_names" {
  description = "Names of all S3 buckets"
  value = concat(
    var.enable_s3_bucket ? [aws_s3_bucket.app_data[0].bucket] : [],
    var.enable_access_logs_bucket ? [aws_s3_bucket.access_logs[0].bucket] : []
  )
}

output "all_s3_bucket_arns" {
  description = "ARNs of all S3 buckets"
  value = concat(
    var.enable_s3_bucket ? [aws_s3_bucket.app_data[0].arn] : [],
    var.enable_access_logs_bucket ? [aws_s3_bucket.access_logs[0].arn] : []
  )
}

output "all_ebs_volume_arns" {
  description = "ARNs of all EBS volumes"
  value       = var.enable_ebs_volume ? aws_ebs_volume.app_data[*].arn : []
}

output "all_cloudwatch_alarm_arns" {
  description = "ARNs of all CloudWatch alarms"
  value = concat(
    var.enable_s3_bucket && var.enable_monitoring ? [aws_cloudwatch_metric_alarm.s3_bucket_size[0].arn] : [],
    var.enable_ebs_volume && var.enable_monitoring ? aws_cloudwatch_metric_alarm.ebs_volume_usage[*].arn : []
  )
}