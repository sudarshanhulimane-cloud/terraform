# Database Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# RDS Configuration
variable "enable_rds" {
  description = "Enable RDS instance"
  type        = bool
  default     = true
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["postgres", "mysql", "mariadb", "oracle-ee", "oracle-se", "oracle-se1", "oracle-se2", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], var.engine)
    error_message = "Engine must be a valid RDS engine."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "14.10"
}

variable "major_engine_version" {
  description = "Major engine version for option groups"
  type        = string
  default     = "14"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.storage_type)
    error_message = "Storage type must be gp2, gp3, io1, io2, or standard."
  }
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# Database Configuration
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

# Network Configuration
variable "subnet_ids" {
  description = "List of subnet IDs for RDS"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "publicly_accessible" {
  description = "Make RDS publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

# Parameter Group Configuration
variable "parameter_group_family" {
  description = "Parameter group family"
  type        = string
  default     = "postgres14"
}

variable "db_parameters" {
  description = "List of database parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "db_options" {
  description = "List of database options"
  type = list(object({
    option_name = string
    port        = optional(number)
    version     = optional(string)
    vpc_security_group_memberships = optional(list(string))
  }))
  default = []
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier"
  type        = string
  default     = null
}

# Monitoring Configuration
variable "monitoring_interval" {
  description = "Monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "Monitoring role ARN"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# Read Replica Configuration
variable "enable_read_replica" {
  description = "Enable read replica"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "Read replica instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "read_replica_allocated_storage" {
  description = "Read replica allocated storage in GB"
  type        = number
  default     = 20
}

variable "read_replica_max_allocated_storage" {
  description = "Read replica maximum allocated storage in GB"
  type        = number
  default     = 100
}

variable "read_replica_storage_type" {
  description = "Read replica storage type"
  type        = string
  default     = "gp2"
}

variable "read_replica_publicly_accessible" {
  description = "Make read replica publicly accessible"
  type        = bool
  default     = false
}

variable "read_replica_multi_az" {
  description = "Enable Multi-AZ for read replica"
  type        = bool
  default     = false
}

variable "read_replica_backup_retention_period" {
  description = "Read replica backup retention period in days"
  type        = number
  default     = 7
}

variable "read_replica_backup_window" {
  description = "Read replica backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "read_replica_maintenance_window" {
  description = "Read replica maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "rds_cpu_threshold" {
  description = "Threshold for RDS CPU utilization"
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold" {
  description = "Threshold for RDS free storage space in bytes"
  type        = number
  default     = 1073741824 # 1 GB
}

variable "rds_connections_threshold" {
  description = "Threshold for RDS database connections"
  type        = number
  default     = 100
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}