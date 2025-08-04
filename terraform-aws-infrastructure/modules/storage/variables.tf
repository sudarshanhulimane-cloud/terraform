# Storage Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "create_additional_ebs_volumes" {
  description = "Whether to create additional EBS volumes"
  type        = bool
  default     = false
}

variable "ebs_volume_count" {
  description = "Number of additional EBS volumes to create"
  type        = number
  default     = 1
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes in GB"
  type        = number
  default     = 100
}

variable "ebs_volume_type" {
  description = "Type of EBS volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "availability_zones" {
  description = "List of availability zones for EBS volumes"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "create_ebs_snapshots" {
  description = "Whether to create EBS snapshots for backup"
  type        = bool
  default     = false
}