# DNS Module - Route 53 Hosted Zones and Records

# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.enable_dns ? 1 : 0

  name = var.domain_name

  tags = merge(var.tags, {
    Name = "${var.name}-hosted-zone"
  })
}

# Route 53 A Record for ALB
resource "aws_route53_record" "alb" {
  count = var.enable_dns && var.enable_alb_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.alb_domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Route 53 A Record for Bastion Host
resource "aws_route53_record" "bastion" {
  count = var.enable_dns && var.enable_bastion_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.bastion_domain_name
  type    = "A"
  ttl     = "300"
  records = [var.bastion_public_ip]
}

# Route 53 CNAME Record for API
resource "aws_route53_record" "api" {
  count = var.enable_dns && var.enable_api_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.api_domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.api_endpoint]
}

# Route 53 MX Record
resource "aws_route53_record" "mx" {
  count = var.enable_dns && var.enable_mx_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "300"

  records = var.mx_records
}

# Route 53 TXT Record for SPF
resource "aws_route53_record" "spf" {
  count = var.enable_dns && var.enable_spf_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 include:_spf.google.com ~all"]
}

# Route 53 TXT Record for DMARC
resource "aws_route53_record" "dmarc" {
  count = var.enable_dns && var.enable_dmarc_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=quarantine; rua=mailto:dmarc@${var.domain_name}"]
}

# Route 53 CAA Record
resource "aws_route53_record" "caa" {
  count = var.enable_dns && var.enable_caa_record ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "CAA"
  ttl     = "300"

  records = var.caa_records
}

# Route 53 NS Records (delegation)
resource "aws_route53_record" "ns" {
  for_each = var.enable_dns && var.enable_ns_records ? toset(var.ns_records) : toset([])

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "NS"
  ttl     = "300"
  records = [each.value]
}

# Route 53 Health Check for ALB
resource "aws_route53_health_check" "alb" {
  count = var.enable_dns && var.enable_health_check ? 1 : 0

  fqdn              = var.alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = merge(var.tags, {
    Name = "${var.name}-alb-health-check"
  })
}

# Route 53 Failover Record
resource "aws_route53_record" "failover" {
  count = var.enable_dns && var.enable_failover ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.failover_domain_name
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.primary_alb_dns_name
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.alb[0].id
}

# Route 53 Secondary Failover Record
resource "aws_route53_record" "failover_secondary" {
  count = var.enable_dns && var.enable_failover ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.failover_domain_name
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.secondary_alb_dns_name
    zone_id                = var.secondary_alb_zone_id
    evaluate_target_health = true
  }
}

# Route 53 Weighted Record
resource "aws_route53_record" "weighted" {
  for_each = var.enable_dns ? var.weighted_records : {}

  zone_id = aws_route53_zone.main[0].zone_id
  name    = each.value.name
  type    = "A"
  ttl     = "300"

  weighted_routing_policy {
    weight = each.value.weight
  }

  alias {
    name                   = each.value.alias_name
    zone_id                = each.value.alias_zone_id
    evaluate_target_health = true
  }
}

# Route 53 Latency Record
resource "aws_route53_record" "latency" {
  for_each = var.enable_dns ? var.latency_records : {}

  zone_id = aws_route53_zone.main[0].zone_id
  name    = each.value.name
  type    = "A"
  ttl     = "300"

  latency_routing_policy {
    region = each.value.region
  }

  alias {
    name                   = each.value.alias_name
    zone_id                = each.value.alias_zone_id
    evaluate_target_health = true
  }
}