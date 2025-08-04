# Load Balancer Module Outputs

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group"
  value       = aws_lb_target_group.app.arn_suffix
}

output "blue_green_target_group_arn" {
  description = "ARN of the blue/green target group"
  value       = var.enable_blue_green ? aws_lb_target_group.app_blue_green[0].arn : null
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}

output "alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB logs"
  value       = aws_s3_bucket.alb_logs.bucket
}