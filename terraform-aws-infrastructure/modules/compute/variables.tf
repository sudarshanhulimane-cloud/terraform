# Compute Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "ID of the bastion security group"
  type        = string
}

variable "app_security_group_id" {
  description = "ID of the application security group"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion host (optional, defaults to latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "app_instance_type" {
  description = "Instance type for application servers"
  type        = string
  default     = "t3.medium"
}

variable "app_ami_id" {
  description = "AMI ID for application servers (optional, defaults to latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "app_root_volume_size" {
  description = "Root volume size for application servers (GB)"
  type        = number
  default     = 20
}

variable "app_min_size" {
  description = "Minimum number of instances in auto scaling group"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum number of instances in auto scaling group"
  type        = number
  default     = 5
}

variable "app_desired_capacity" {
  description = "Desired number of instances in auto scaling group"
  type        = number
  default     = 2
}

variable "target_group_arn" {
  description = "ARN of the target group for auto scaling group"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}