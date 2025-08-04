# Database Module - RDS Instances, Parameter Groups, and Subnet Groups

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-db-subnet-group"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  count = var.enable_rds ? 1 : 0

  family = var.parameter_group_family
  name   = "${var.name}-db-parameter-group"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-db-parameter-group"
  })
}

# RDS Option Group
resource "aws_db_option_group" "main" {
  count = var.enable_rds ? 1 : 0

  engine_name              = var.engine
  major_engine_version     = var.major_engine_version
  name                     = "${var.name}-db-option-group"

  dynamic "option" {
    for_each = var.db_options
    content {
      option_name = option.value.option_name
      port        = lookup(option.value, "port", null)
      version     = lookup(option.value, "version", null)

      dynamic "vpc_security_group_memberships" {
        for_each = lookup(option.value, "vpc_security_group_memberships", [])
        content {
          vpc_security_group_id = vpc_security_group_memberships.value
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-db-option-group"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  count = var.enable_rds ? 1 : 0

  identifier = "${var.name}-db"

  # Engine Configuration
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = var.storage_type
  storage_encrypted    = var.storage_encrypted
  kms_key_id          = var.kms_key_id

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = var.publicly_accessible
  multi_az              = var.multi_az

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  skip_final_snapshot   = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.main[0].name
  option_group_name   = aws_db_option_group.main[0].name

  # Monitoring Configuration
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  # Deletion Protection
  deletion_protection = var.deletion_protection

  # Tags
  tags = merge(var.tags, {
    Name = "${var.name}-db"
    Role = "database"
  })

  lifecycle {
    ignore_changes = [
      password,
    ]
  }
}

# RDS Read Replica (if enabled)
resource "aws_db_instance" "read_replica" {
  count = var.enable_rds && var.enable_read_replica ? 1 : 0

  identifier = "${var.name}-db-read-replica"

  # Source Configuration
  replicate_source_db = aws_db_instance.main[0].identifier

  # Engine Configuration
  instance_class       = var.read_replica_instance_class
  allocated_storage    = var.read_replica_allocated_storage
  max_allocated_storage = var.read_replica_max_allocated_storage
  storage_type         = var.read_replica_storage_type
  storage_encrypted    = var.storage_encrypted
  kms_key_id          = var.kms_key_id

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = var.read_replica_publicly_accessible
  multi_az              = var.read_replica_multi_az

  # Backup Configuration
  backup_retention_period = var.read_replica_backup_retention_period
  backup_window          = var.read_replica_backup_window
  maintenance_window     = var.read_replica_maintenance_window
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  skip_final_snapshot   = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name}-db-read-replica-final-snapshot"

  # Monitoring Configuration
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  # Deletion Protection
  deletion_protection = var.deletion_protection

  # Tags
  tags = merge(var.tags, {
    Name = "${var.name}-db-read-replica"
    Role = "database-read-replica"
  })
}

# CloudWatch Alarm for RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count = var.enable_rds && var.enable_monitoring ? 1 : 0

  alarm_name          = "rds-cpu-utilization-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.rds_cpu_threshold
  alarm_description  = "This metric monitors RDS CPU utilization"
  alarm_actions      = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main[0].identifier
  }
}

# CloudWatch Alarm for RDS Free Storage Space
resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  count = var.enable_rds && var.enable_monitoring ? 1 : 0

  alarm_name          = "rds-free-storage-space-${var.name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "FreeStorageSpace"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.rds_free_storage_threshold
  alarm_description  = "This metric monitors RDS free storage space"
  alarm_actions      = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main[0].identifier
  }
}

# CloudWatch Alarm for RDS Database Connections
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count = var.enable_rds && var.enable_monitoring ? 1 : 0

  alarm_name          = "rds-database-connections-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "DatabaseConnections"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.rds_connections_threshold
  alarm_description  = "This metric monitors RDS database connections"
  alarm_actions      = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main[0].identifier
  }
}

# CloudWatch Alarm for Read Replica CPU Utilization
resource "aws_cloudwatch_metric_alarm" "read_replica_cpu" {
  count = var.enable_rds && var.enable_read_replica && var.enable_monitoring ? 1 : 0

  alarm_name          = "rds-read-replica-cpu-utilization-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.rds_cpu_threshold
  alarm_description  = "This metric monitors RDS read replica CPU utilization"
  alarm_actions      = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.read_replica[0].identifier
  }
}