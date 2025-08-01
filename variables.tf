variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "terraform-eks"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_eks_auto_mode" {
  description = "Enable EKS Auto Mode"
  type        = bool
  default     = true
}

variable "enable_fargate" {
  description = "Enable Fargate profiles"
  type        = bool
  default     = true
}

variable "enable_api_gateway" {
  description = "Enable API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_endpoint_type" {
  description = "API Gateway endpoint type"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.api_gateway_endpoint_type)
    error_message = "Endpoint type must be EDGE, REGIONAL, or PRIVATE."
  }
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_group_instance_types" {
  description = "Instance types for the EKS node group (when auto mode is disabled)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_capacity" {
  description = "Desired number of nodes in the node group (when auto mode is disabled)"
  type        = number
  default     = 2
}

variable "node_group_max_capacity" {
  description = "Maximum number of nodes in the node group (when auto mode is disabled)"
  type        = number
  default     = 4
}

variable "node_group_min_capacity" {
  description = "Minimum number of nodes in the node group (when auto mode is disabled)"
  type        = number
  default     = 1
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Environment = "dev"
  }
}