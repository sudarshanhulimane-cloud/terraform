# DNS Module - Route 53 Hosted Zone and Records

# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0

  name = var.domain_name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-hosted-zone"
  })
}

# A Record for ALB
resource "aws_route53_record" "alb" {
  count = var.domain_name != "" ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# A Record for www subdomain
resource "aws_route53_record" "www" {
  count = var.domain_name != "" ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# A Record for API subdomain
resource "aws_route53_record" "api" {
  count = var.domain_name != "" ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# A Record for Bastion Host
resource "aws_route53_record" "bastion" {
  count = var.domain_name != "" && var.bastion_public_ip != "" ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "bastion.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.bastion_public_ip]
}

# MX Record for email (optional)
resource "aws_route53_record" "mx" {
  count = var.domain_name != "" && length(var.mx_records) > 0 ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 300
  records = var.mx_records
}

# TXT Record for domain verification (optional)
resource "aws_route53_record" "txt" {
  count = var.domain_name != "" && length(var.txt_records) > 0 ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 300
  records = var.txt_records
}

# CNAME Record for additional subdomains
resource "aws_route53_record" "cname" {
  for_each = var.domain_name != "" ? var.cname_records : {}

  zone_id = aws_route53_zone.main[0].zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}

# Health Check for ALB
resource "aws_route53_health_check" "alb" {
  count = var.domain_name != "" && var.enable_health_checks ? 1 : 0

  fqdn                            = var.alb_dns_name
  port                            = 80
  type                            = "HTTP"
  resource_path                   = "/health"
  failure_threshold               = "3"
  request_interval                = "30"
  cloudwatch_logs_region          = data.aws_region.current.name
  cloudwatch_alarm_region         = data.aws_region.current.name
  insufficient_data_health_status = "Failure"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-health-check"
  })
}

# CloudWatch Alarm for Health Check
resource "aws_cloudwatch_metric_alarm" "health_check" {
  count = var.domain_name != "" && var.enable_health_checks ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-route53-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitors Route53 health check"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    HealthCheckId = aws_route53_health_check.alb[0].id
  }

  tags = var.common_tags
}

# Data source for current region
data "aws_region" "current" {}