variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPC endpoint"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC endpoint"
  type        = list(string)
}

variable "api_description" {
  description = "Description for the API Gateway"
  type        = string
  default     = "API Gateway for EKS services"
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "v1"
}

variable "throttle_rate_limit" {
  description = "Throttle rate limit for API Gateway"
  type        = number
  default     = 1000
}

variable "throttle_burst_limit" {
  description = "Throttle burst limit for API Gateway"
  type        = number
  default     = 2000
}

variable "enable_vpc_endpoint" {
  description = "Enable VPC endpoint for private API access"
  type        = bool
  default     = true
}

variable "endpoint_type" {
  description = "API Gateway endpoint type"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "Endpoint type must be EDGE, REGIONAL, or PRIVATE."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}