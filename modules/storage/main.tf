# Storage Module - S3 Buckets and EBS Volumes

# S3 Bucket for Application Data
resource "aws_s3_bucket" "app_data" {
  count = var.enable_s3_bucket ? 1 : 0

  bucket = "${var.name}-app-data-${random_string.bucket_suffix[0].result}"

  tags = merge(var.tags, {
    Name = "${var.name}-app-data"
    Purpose = "application-data"
  })
}

# Random string for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  count = var.enable_s3_bucket ? 1 : 0

  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "app_data" {
  count = var.enable_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.app_data[0].id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  count = var.enable_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.app_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "app_data" {
  count = var.enable_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.app_data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "app_data" {
  count = var.enable_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.app_data[0].id

  rule {
    id     = "app-data-lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.s3_lifecycle_expiration_days
    }
  }
}

# S3 Bucket for Access Logs
resource "aws_s3_bucket" "access_logs" {
  count = var.enable_access_logs_bucket ? 1 : 0

  bucket = "${var.name}-access-logs-${random_string.access_logs_suffix[0].result}"

  tags = merge(var.tags, {
    Name = "${var.name}-access-logs"
    Purpose = "access-logs"
  })
}

# Random string for access logs bucket name uniqueness
resource "random_string" "access_logs_suffix" {
  count = var.enable_access_logs_bucket ? 1 : 0

  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning for Access Logs
resource "aws_s3_bucket_versioning" "access_logs" {
  count = var.enable_access_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption for Access Logs
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count = var.enable_access_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block for Access Logs
resource "aws_s3_bucket_public_access_block" "access_logs" {
  count = var.enable_access_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration for Access Logs
resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count = var.enable_access_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    id     = "access-logs-lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = var.access_logs_lifecycle_expiration_days
    }
  }
}

# EBS Volume for Application Data
resource "aws_ebs_volume" "app_data" {
  count = var.enable_ebs_volume ? var.ebs_volume_count : 0

  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  encrypted         = true
  kms_key_id        = var.ebs_kms_key_id

  tags = merge(var.tags, {
    Name = "${var.name}-app-data-${count.index + 1}"
    Purpose = "application-data"
  })
}

# EBS Volume Attachment
resource "aws_volume_attachment" "app_data" {
  count = var.enable_ebs_volume && var.attach_ebs_volume ? var.ebs_volume_count : 0

  device_name = var.ebs_device_names[count.index % length(var.ebs_device_names)]
  volume_id   = aws_ebs_volume.app_data[count.index].id
  instance_id = var.instance_ids[count.index % length(var.instance_ids)]
}

# EBS Snapshot for Backup
resource "aws_ebs_snapshot" "app_data" {
  count = var.enable_ebs_snapshot ? var.ebs_volume_count : 0

  volume_id = aws_ebs_volume.app_data[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name}-app-data-snapshot-${count.index + 1}"
    Purpose = "backup"
  })
}

# CloudWatch Alarm for S3 Bucket Size
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  count = var.enable_s3_bucket && var.enable_monitoring ? 1 : 0

  alarm_name          = "s3-bucket-size-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "BucketSizeBytes"
  namespace          = "AWS/S3"
  period             = "86400" # 24 hours
  statistic          = "Average"
  threshold          = var.s3_bucket_size_threshold
  alarm_description  = "This metric monitors S3 bucket size"
  alarm_actions      = var.alarm_actions

  dimensions = {
    BucketName = aws_s3_bucket.app_data[0].bucket
    StorageType = "StandardStorage"
  }
}

# CloudWatch Alarm for EBS Volume Usage
resource "aws_cloudwatch_metric_alarm" "ebs_volume_usage" {
  count = var.enable_ebs_volume && var.enable_monitoring ? var.ebs_volume_count : 0

  alarm_name          = "ebs-volume-usage-${var.name}-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "VolumeIdleTime"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = var.ebs_volume_usage_threshold
  alarm_description  = "This metric monitors EBS volume usage"
  alarm_actions      = var.alarm_actions

  dimensions = {
    VolumeId = aws_ebs_volume.app_data[count.index].id
  }
}