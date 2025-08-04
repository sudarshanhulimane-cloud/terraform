# DNS Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  type        = string
}

variable "bastion_public_ip" {
  description = "Public IP of the bastion host"
  type        = string
  default     = ""
}

variable "enable_health_checks" {
  description = "Enable Route 53 health checks"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for health check alarms"
  type        = string
  default     = ""
}

variable "mx_records" {
  description = "MX records for the domain"
  type        = list(string)
  default     = []
}

variable "txt_records" {
  description = "TXT records for the domain"
  type        = list(string)
  default     = []
}

variable "cname_records" {
  description = "CNAME records for subdomains"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}