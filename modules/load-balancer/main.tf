# Load Balancer Module - Application Load Balancer, Target Groups, and Listeners

# Application Load Balancer
resource "aws_lb" "main" {
  count = var.enable_load_balancer ? 1 : 0

  name               = "alb-${var.name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets           = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.enable_access_logs
  }

  tags = merge(var.tags, {
    Name = "alb-${var.name}"
    Role = "load-balancer"
  })
}

# Target Group for HTTP
resource "aws_lb_target_group" "http" {
  count = var.enable_load_balancer ? 1 : 0

  name        = "tg-http-${var.name}"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "tg-http-${var.name}"
  })
}

# Target Group for HTTPS
resource "aws_lb_target_group" "https" {
  count = var.enable_load_balancer && var.enable_https ? 1 : 0

  name        = "tg-https-${var.name}"
  port        = var.target_port
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "tg-https-${var.name}"
  })
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  count = var.enable_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]
      content {
        target_group_arn = aws_lb_target_group.http[0].arn
      }
    }
  }

  tags = merge(var.tags, {
    Name = "listener-http-${var.name}"
  })
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.enable_load_balancer && var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[0].arn
  }

  tags = merge(var.tags, {
    Name = "listener-https-${var.name}"
  })
}

# Additional HTTP Listener Rules
resource "aws_lb_listener_rule" "http_rules" {
  for_each = var.enable_load_balancer ? var.http_listener_rules : {}

  listener_arn = aws_lb_listener.http[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http[0].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  tags = merge(var.tags, {
    Name = "rule-${each.key}-${var.name}"
  })
}

# Additional HTTPS Listener Rules
resource "aws_lb_listener_rule" "https_rules" {
  for_each = var.enable_load_balancer && var.enable_https ? var.https_listener_rules : {}

  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[0].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  tags = merge(var.tags, {
    Name = "rule-${each.key}-${var.name}"
  })
}

# Target Group Attachments for EC2 Instances
resource "aws_lb_target_group_attachment" "ec2" {
  for_each = var.enable_load_balancer && var.target_type == "instance" ? toset(var.target_ids) : toset([])

  target_group_arn = var.enable_https ? aws_lb_target_group.https[0].arn : aws_lb_target_group.http[0].arn
  target_id        = each.value
  port             = var.target_port
}

# Target Group Attachments for IP Addresses
resource "aws_lb_target_group_attachment" "ip" {
  for_each = var.enable_load_balancer && var.target_type == "ip" ? toset(var.target_ids) : toset([])

  target_group_arn = var.enable_https ? aws_lb_target_group.https[0].arn : aws_lb_target_group.http[0].arn
  target_id        = each.value
  port             = var.target_port
}

# CloudWatch Alarm for ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.enable_load_balancer && var.enable_monitoring ? 1 : 0

  alarm_name          = "alb-5xx-errors-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "HTTPCode_ELB_5XX_Count"
  namespace          = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.alb_5xx_threshold
  alarm_description  = "This metric monitors ALB 5XX errors"
  alarm_actions      = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
    TargetGroup  = var.enable_https ? aws_lb_target_group.https[0].arn_suffix : aws_lb_target_group.http[0].arn_suffix
  }
}

# CloudWatch Alarm for ALB Target 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  count = var.enable_load_balancer && var.enable_monitoring ? 1 : 0

  alarm_name          = "alb-target-5xx-errors-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "HTTPCode_Target_5XX_Count"
  namespace          = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.alb_target_5xx_threshold
  alarm_description  = "This metric monitors ALB target 5XX errors"
  alarm_actions      = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
    TargetGroup  = var.enable_https ? aws_lb_target_group.https[0].arn_suffix : aws_lb_target_group.http[0].arn_suffix
  }
}

# CloudWatch Alarm for ALB Response Time
resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  count = var.enable_load_balancer && var.enable_monitoring ? 1 : 0

  alarm_name          = "alb-response-time-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "TargetResponseTime"
  namespace          = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Average"
  threshold          = var.alb_response_time_threshold
  alarm_description  = "This metric monitors ALB response time"
  alarm_actions      = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main[0].arn_suffix
    TargetGroup  = var.enable_https ? aws_lb_target_group.https[0].arn_suffix : aws_lb_target_group.http[0].arn_suffix
  }
}