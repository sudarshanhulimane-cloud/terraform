# Compute Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Bastion Host Variables
variable "enable_bastion" {
  description = "Enable bastion host"
  type        = bool
  default     = true
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion host (if null, uses latest Amazon Linux)"
  type        = string
  default     = null
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "Key pair name for bastion host"
  type        = string
  default     = null
}

variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

# Application Server Variables
variable "enable_app_server" {
  description = "Enable application server instances"
  type        = bool
  default     = false
}

variable "app_server_count" {
  description = "Number of application server instances"
  type        = number
  default     = 2
}

variable "app_server_ami_id" {
  description = "AMI ID for application servers (if null, uses latest Amazon Linux)"
  type        = string
  default     = null
}

variable "app_server_instance_type" {
  description = "Instance type for application servers"
  type        = string
  default     = "t3.small"
}

variable "app_server_key_name" {
  description = "Key pair name for application servers"
  type        = string
  default     = null
}

variable "app_server_security_group_id" {
  description = "Security group ID for application servers"
  type        = string
}

variable "app_server_iam_instance_profile" {
  description = "IAM instance profile for application servers"
  type        = string
  default     = null
}

variable "app_server_root_volume_size" {
  description = "Root volume size for application servers (GB)"
  type        = number
  default     = 20
}

variable "app_server_root_volume_type" {
  description = "Root volume type for application servers"
  type        = string
  default     = "gp3"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

# Auto Scaling Group Variables
variable "enable_auto_scaling_group" {
  description = "Enable auto scaling group"
  type        = bool
  default     = false
}

variable "asg_desired_capacity" {
  description = "Desired capacity for auto scaling group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size for auto scaling group"
  type        = number
  default     = 4
}

variable "asg_min_size" {
  description = "Minimum size for auto scaling group"
  type        = number
  default     = 1
}

variable "target_group_arns" {
  description = "Target group ARNs for auto scaling group"
  type        = list(string)
  default     = []
}

# Auto Scaling Policy Variables
variable "enable_cpu_scaling" {
  description = "Enable CPU-based auto scaling"
  type        = bool
  default     = true
}

variable "cpu_scaling_adjustment" {
  description = "Number of instances to add/remove when scaling"
  type        = number
  default     = 1
}

variable "cpu_scaling_cooldown" {
  description = "Cooldown period for CPU scaling (seconds)"
  type        = number
  default     = 300
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for scaling"
  type        = number
  default     = 80
}