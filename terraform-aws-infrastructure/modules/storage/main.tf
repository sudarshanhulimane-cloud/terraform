# Storage Module - S3 Bucket and EBS Volumes

# Generate a random suffix for the S3 bucket name to ensure uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-storage-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-storage-bucket"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "delete_incomplete_multipart_uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "transition_to_ia"
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
      days = 365
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Optional EBS Volumes for additional storage
resource "aws_ebs_volume" "additional" {
  count = var.create_additional_ebs_volumes ? var.ebs_volume_count : 0

  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  encrypted         = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ebs-volume-${count.index + 1}"
  })
}

# EBS Volume Snapshots (for backup)
resource "aws_ebs_snapshot" "backup" {
  count = var.create_ebs_snapshots && var.create_additional_ebs_volumes ? var.ebs_volume_count : 0

  volume_id   = aws_ebs_volume.additional[count.index].id
  description = "Backup snapshot for ${var.project_name}-${var.environment}-ebs-volume-${count.index + 1}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ebs-snapshot-${count.index + 1}"
  })
}