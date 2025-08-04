# Storage Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# S3 Bucket Configuration
variable "enable_s3_bucket" {
  description = "Enable S3 bucket for application data"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_lifecycle_expiration_days" {
  description = "Number of days before S3 objects expire"
  type        = number
  default     = 2555 # 7 years
}

# Access Logs S3 Bucket Configuration
variable "enable_access_logs_bucket" {
  description = "Enable S3 bucket for access logs"
  type        = bool
  default     = false
}

variable "access_logs_lifecycle_expiration_days" {
  description = "Number of days before access logs expire"
  type        = number
  default     = 365
}

# EBS Volume Configuration
variable "enable_ebs_volume" {
  description = "Enable EBS volumes"
  type        = bool
  default     = false
}

variable "ebs_volume_count" {
  description = "Number of EBS volumes to create"
  type        = number
  default     = 1
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes in GB"
  type        = number
  default     = 100
}

variable "ebs_volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.ebs_volume_type)
    error_message = "EBS volume type must be gp2, gp3, io1, io2, st1, or sc1."
  }
}

variable "ebs_kms_key_id" {
  description = "KMS key ID for EBS volume encryption"
  type        = string
  default     = null
}

variable "attach_ebs_volume" {
  description = "Attach EBS volumes to instances"
  type        = bool
  default     = false
}

variable "ebs_device_names" {
  description = "List of device names for EBS volume attachments"
  type        = list(string)
  default     = ["/dev/sdf", "/dev/sdg", "/dev/sdh", "/dev/sdi"]
}

variable "instance_ids" {
  description = "List of instance IDs for EBS volume attachments"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones for EBS volumes"
  type        = list(string)
  default     = []
}

# EBS Snapshot Configuration
variable "enable_ebs_snapshot" {
  description = "Enable EBS snapshots for backup"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "s3_bucket_size_threshold" {
  description = "Threshold for S3 bucket size alarm in bytes"
  type        = number
  default     = 10737418240 # 10 GB
}

variable "ebs_volume_usage_threshold" {
  description = "Threshold for EBS volume usage alarm"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}