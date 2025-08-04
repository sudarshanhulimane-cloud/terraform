# Database Module - RDS Instance with Parameter Groups and Subnet Groups

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  family = var.db_engine == "postgres" ? "postgres${split(".", var.db_engine_version)[0]}" : "mysql${split(".", var.db_engine_version)[0]}.0"
  name   = "${var.project_name}-${var.environment}-db-params"

  # PostgreSQL parameters
  dynamic "parameter" {
    for_each = var.db_engine == "postgres" ? var.postgres_parameters : {}
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  # MySQL parameters
  dynamic "parameter" {
    for_each = var.db_engine == "mysql" ? var.mysql_parameters : {}
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-params"
  })
}

# DB Option Group (for MySQL)
resource "aws_db_option_group" "main" {
  count = var.db_engine == "mysql" ? 1 : 0

  name                     = "${var.project_name}-${var.environment}-db-options"
  option_group_description = "Option group for ${var.project_name} ${var.environment}"
  engine_name              = "mysql"
  major_engine_version     = split(".", var.db_engine_version)[0]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-options"
  })
}

# Generate random password if not provided
resource "random_password" "db_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project_name}-${var.environment}-db-password"
  description = "Database password for ${var.project_name} ${var.environment}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password != "" ? var.db_password : random_password.db_password[0].result
    engine   = var.db_engine
    host     = aws_db_instance.main.endpoint
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine configuration
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage configuration
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = true

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password != "" ? var.db_password : random_password.db_password[0].result
  port     = var.db_engine == "postgres" ? 5432 : 3306

  # Network and security
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  # Parameter and option groups
  parameter_group_name = aws_db_parameter_group.main.name
  option_group_name    = var.db_engine == "mysql" ? aws_db_option_group.main[0].name : null

  # Backup and maintenance
  backup_retention_period   = var.backup_retention
  backup_window            = "03:00-04:00"
  maintenance_window       = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = true

  # Multi-AZ and monitoring
  multi_az               = var.multi_az
  monitoring_interval    = 60
  monitoring_role_arn    = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Deletion protection and final snapshot
  deletion_protection       = var.deletion_protection
  skip_final_snapshot      = !var.final_snapshot_enabled
  final_snapshot_identifier = var.final_snapshot_enabled ? "${var.project_name}-${var.environment}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })

  depends_on = [aws_db_subnet_group.main, aws_db_parameter_group.main]
}

# RDS Monitoring Role
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-monitoring-role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Read Replica (optional)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.project_name}-${var.environment}-db-read-replica"

  replicate_source_db = aws_db_instance.main.id
  instance_class      = var.read_replica_instance_class

  publicly_accessible = false

  auto_minor_version_upgrade = true
  monitoring_interval       = 60
  monitoring_role_arn       = aws_iam_role.rds_monitoring.arn

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-read-replica"
  })
}