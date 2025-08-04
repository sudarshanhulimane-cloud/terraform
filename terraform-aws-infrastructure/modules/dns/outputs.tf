# DNS Module Outputs

output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].zone_id : null
}

output "zone_arn" {
  description = "Route 53 hosted zone ARN"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].arn : null
}

output "name_servers" {
  description = "Route 53 name servers"
  value       = var.domain_name != "" ? aws_route53_zone.main[0].name_servers : []
}

output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}

output "alb_record_name" {
  description = "ALB A record name"
  value       = var.domain_name != "" ? aws_route53_record.alb[0].name : null
}

output "www_record_name" {
  description = "WWW A record name"
  value       = var.domain_name != "" ? aws_route53_record.www[0].name : null
}

output "api_record_name" {
  description = "API A record name"
  value       = var.domain_name != "" ? aws_route53_record.api[0].name : null
}

output "bastion_record_name" {
  description = "Bastion A record name"
  value       = var.domain_name != "" && var.bastion_public_ip != "" ? aws_route53_record.bastion[0].name : null
}

output "health_check_id" {
  description = "Route 53 health check ID"
  value       = var.domain_name != "" && var.enable_health_checks ? aws_route53_health_check.alb[0].id : null
}