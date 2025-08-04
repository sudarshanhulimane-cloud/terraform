# Database Module Variables

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

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the RDS security group"
  type        = string
}

variable "db_engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for RDS instance (GB)"
  type        = number
  default     = 100
}

variable "db_storage_type" {
  description = "Storage type for RDS instance"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password for the database (leave empty to auto-generate)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection for RDS instance"
  type        = bool
  default     = false
}

variable "final_snapshot_enabled" {
  description = "Enable final snapshot when RDS instance is deleted"
  type        = bool
  default     = true
}

variable "create_read_replica" {
  description = "Create a read replica for the RDS instance"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "Instance class for read replica"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_parameters" {
  description = "PostgreSQL parameters"
  type        = map(string)
  default = {
    "shared_preload_libraries" = "pg_stat_statements"
    "log_statement"           = "all"
    "log_min_duration_statement" = "1000"
  }
}

variable "mysql_parameters" {
  description = "MySQL parameters"
  type        = map(string)
  default = {
    "innodb_buffer_pool_size" = "{DBInstanceClassMemory*3/4}"
    "slow_query_log"          = "1"
    "long_query_time"         = "1"
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}