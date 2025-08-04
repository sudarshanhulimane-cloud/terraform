# Load Balancer Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Load Balancer Configuration
variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target groups"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for the load balancer"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2 for the load balancer"
  type        = bool
  default     = true
}

# Access Logs Configuration
variable "enable_access_logs" {
  description = "Enable access logs for the load balancer"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = "alb-logs"
}

# HTTPS Configuration
variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# Target Group Configuration
variable "target_type" {
  description = "Type of target (instance, ip, or lambda)"
  type        = string
  default     = "instance"
  validation {
    condition     = contains(["instance", "ip", "lambda"], var.target_type)
    error_message = "Target type must be instance, ip, or lambda."
  }
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_ids" {
  description = "List of target IDs (instance IDs or IP addresses)"
  type        = list(string)
  default     = []
}

# Health Check Configuration
variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Health check port"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

variable "health_check_matcher" {
  description = "Health check matcher (HTTP codes)"
  type        = string
  default     = "200"
}

# Listener Rules Configuration
variable "http_listener_rules" {
  description = "Map of HTTP listener rules"
  type = map(object({
    priority       = number
    path_patterns  = list(string)
  }))
  default = {}
}

variable "https_listener_rules" {
  description = "Map of HTTPS listener rules"
  type = map(object({
    priority       = number
    path_patterns  = list(string)
  }))
  default = {}
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5XX errors"
  type        = number
  default     = 10
}

variable "alb_target_5xx_threshold" {
  description = "Threshold for ALB target 5XX errors"
  type        = number
  default     = 10
}

variable "alb_response_time_threshold" {
  description = "Threshold for ALB response time in seconds"
  type        = number
  default     = 5
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}