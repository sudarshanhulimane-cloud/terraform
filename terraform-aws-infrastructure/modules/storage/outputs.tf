# Storage Module Outputs

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "ebs_volume_ids" {
  description = "IDs of the additional EBS volumes"
  value       = aws_ebs_volume.additional[*].id
}

output "ebs_volume_arns" {
  description = "ARNs of the additional EBS volumes"
  value       = aws_ebs_volume.additional[*].arn
}

output "ebs_snapshot_ids" {
  description = "IDs of the EBS snapshots"
  value       = aws_ebs_snapshot.backup[*].id
}