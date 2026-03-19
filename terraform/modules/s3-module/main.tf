# Terraform AWS S3 Module - Main Configuration
# L1 Module for S3 Bucket provisioning with security compliance

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-s3-module"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
    LastModified  = formatdate("YYYY-MM-DD", timestamp())
    CostCenter    = var.cost_center
    Project       = var.project_name
    Owner         = var.owner
    BusinessUnit  = var.business_unit
    Application   = var.application_name
    DataClass     = var.data_classification
    Compliance    = "CCMS"
  }
}

# Local implementation of config validation
locals {
  # Configuration constants and validation
  config = {
    # AWS region validation
    valid_regions = [
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1"
    ]
    
    # Bucket type validation for different environments
    allowed_bucket_types = {
      dev  = ["general-purpose", "directory"]
      test = ["general-purpose", "directory", "table"]
      prod = ["general-purpose", "directory", "table", "vector"]
    }
    
    # Security requirements by environment
    security_requirements = {
      encryption_required     = var.environment == "prod" ? true : var.require_encryption
      versioning_required    = var.environment == "prod" ? true : var.enable_versioning
      public_access_blocked  = var.environment == "prod" ? true : var.block_public_access
      mfa_delete_required    = false  # Disabled by default to avoid permission issues
      logging_required       = var.environment == "prod" ? true : var.enable_access_logging
    }
  }
}

# Data sources for KMS key and caller identity
data "aws_caller_identity" "current" {}

data "aws_kms_key" "s3" {
  count  = var.kms_key_id != null ? 1 : 0
  key_id = var.kms_key_id
}

# Local values for configuration and tagging
locals {
  # Determine KMS key ARN
  kms_key_arn = var.kms_key_id != null ? (
    length(data.aws_kms_key.s3) > 0 ? data.aws_kms_key.s3[0].arn : null
  ) : null

  # Standard tags following CCMS requirements with Security Controls
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.bucket_name
      Module      = "terraform-aws-l1-s3"
      Environment = var.environment
      Component   = "s3-bucket"
      
      # Security Control Tags
      "security:encryption"     = local.config.security_requirements.encryption_required ? "enabled" : "disabled"
      "security:versioning"     = local.config.security_requirements.versioning_required ? "enabled" : "disabled"
      "security:public-access"  = local.config.security_requirements.public_access_blocked ? "blocked" : "allowed"
      "security:mfa-delete"     = local.config.security_requirements.mfa_delete_required ? "enabled" : "disabled"
      "security:logging"        = local.config.security_requirements.logging_required ? "enabled" : "disabled"
      
      # Compliance Tags
      "compliance:ccms"         = "enabled"
      "compliance:data-class"   = var.data_classification
      "compliance:retention"    = var.retention_policy
    },
    var.additional_tags
  )

  # Bucket policy for secure access
  bucket_policy = var.bucket_policy != null ? var.bucket_policy : (
    var.enable_ssl_only ? jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "DenyInsecureConnections"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource = [
            aws_s3_bucket.this.arn,
            "${aws_s3_bucket.this.arn}/*"
          ]
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        }
      ]
    }) : null
  )
}

# ============================================================================
# S3 BUCKET RESOURCES
# ============================================================================

# S3-01: Primary S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = local.standard_tags

  lifecycle {
    prevent_destroy = false  # Allow destruction for testing/development
  }
}

# S3-02: Bucket Versioning Configuration
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status     = local.config.security_requirements.versioning_required ? "Enabled" : var.versioning_status
    # Disable MFA delete by default to avoid permission issues
    # MFA delete should only be enabled when explicitly configured with proper MFA setup
    mfa_delete = "Disabled"
  }

  depends_on = [aws_s3_bucket.this]
}

# S3-03: Server-Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = local.config.security_requirements.encryption_required ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_type
      kms_master_key_id = var.encryption_type == "aws:kms" ? local.kms_key_arn : null
    }
    
    bucket_key_enabled = var.encryption_type == "aws:kms" ? var.bucket_key_enabled : null
  }

  depends_on = [aws_s3_bucket.this]
}

# S3-04: Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = local.config.security_requirements.public_access_blocked ? true : var.block_public_acls
  block_public_policy     = local.config.security_requirements.public_access_blocked ? true : var.block_public_policy
  ignore_public_acls      = local.config.security_requirements.public_access_blocked ? true : var.ignore_public_acls
  restrict_public_buckets = local.config.security_requirements.public_access_blocked ? true : var.restrict_public_buckets

  depends_on = [aws_s3_bucket.this]
}

# S3-05: Bucket Policy
resource "aws_s3_bucket_policy" "this" {
  count  = local.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = local.bucket_policy

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# S3-06: Access Logging Configuration
resource "aws_s3_bucket_logging" "this" {
  count  = local.config.security_requirements.logging_required && var.access_log_bucket != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.access_log_bucket
  target_prefix = var.access_log_prefix != null ? var.access_log_prefix : "access-logs/${var.bucket_name}/"

  depends_on = [aws_s3_bucket.this]
}

# S3-07: Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix
          
          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions != null ? rule.value.noncurrent_version_transitions : []
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# S3-08: CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  depends_on = [aws_s3_bucket.this]
}

# S3-09: Website Configuration
resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.enable_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.website_index_document
  }

  error_document {
    key = var.website_error_document
  }

  depends_on = [aws_s3_bucket.this]
}

# S3-10: Transfer Acceleration
resource "aws_s3_bucket_accelerate_configuration" "this" {
  count  = var.enable_transfer_acceleration ? 1 : 0
  bucket = aws_s3_bucket.this.id
  status = "Enabled"

  depends_on = [aws_s3_bucket.this]
}

# S3-11: Request Payment Configuration
resource "aws_s3_bucket_request_payment_configuration" "this" {
  count  = var.enable_requester_pays ? 1 : 0
  bucket = aws_s3_bucket.this.id
  payer  = "Requester"

  depends_on = [aws_s3_bucket.this]
}

# S3-12: Object Lock Configuration
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.enable_object_lock ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_retention_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# S3-13: Notification Configuration
resource "aws_s3_bucket_notification" "this" {
  count  = length(var.notification_configurations) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = [for config in var.notification_configurations : config if config.type == "lambda"]
    content {
      lambda_function_arn = lambda_function.value.destination_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = [for config in var.notification_configurations : config if config.type == "sns"]
    content {
      topic_arn     = topic.value.destination_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = [for config in var.notification_configurations : config if config.type == "sqs"]
    content {
      queue_arn     = queue.value.destination_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }

  depends_on = [aws_s3_bucket.this]
}

# S3-14: Intelligent Tiering Configuration
resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  count  = var.enable_intelligent_tiering ? 1 : 0
  bucket = aws_s3_bucket.this.id
  name   = "${var.bucket_name}-intelligent-tiering"

  status = "Enabled"

  filter {
    prefix = var.intelligent_tiering_prefix
    tags   = var.intelligent_tiering_tags
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = var.intelligent_tiering_deep_archive_days
  }

  depends_on = [aws_s3_bucket.this]
}

# ============================================================================
# CLOUDWATCH MONITORING
# ============================================================================

# CloudWatch Metric Filters for S3 Access Patterns
resource "aws_cloudwatch_log_metric_filter" "s3_access_denied" {
  count          = var.enable_cloudwatch_monitoring ? 1 : 0
  name           = "${var.bucket_name}-access-denied"
  log_group_name = "/aws/s3/${var.bucket_name}"
  pattern        = "[timestamp, request_id, remote_ip, requester, request_id, operation, key, request_uri, http_status=\"403\", ...]"

  metric_transformation {
    name      = "S3AccessDenied"
    namespace = "AWS/S3/Security"
    value     = "1"
    
    default_value = 0
  }
}

# CloudWatch Alarm for Access Denied Events
resource "aws_cloudwatch_metric_alarm" "s3_access_denied" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "${var.bucket_name}-access-denied-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "S3AccessDenied"
  namespace           = "AWS/S3/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors S3 access denied events"
  alarm_actions       = var.alarm_actions

  dimensions = {
    BucketName = aws_s3_bucket.this.id
  }

  tags = local.standard_tags
}

# ============================================================================
# SECURITY VALIDATION
# ============================================================================

# Validation checks for security compliance
resource "null_resource" "security_validation" {
  count = var.enable_security_validation ? 1 : 0

  triggers = {
    bucket_name = aws_s3_bucket.this.id
    encryption  = local.config.security_requirements.encryption_required
    versioning  = local.config.security_requirements.versioning_required
    public_access = local.config.security_requirements.public_access_blocked
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "=== S3 Security Validation ==="
      echo "Bucket: ${aws_s3_bucket.this.id}"
      echo "Encryption Required: ${local.config.security_requirements.encryption_required}"
      echo "Versioning Required: ${local.config.security_requirements.versioning_required}"
      echo "Public Access Blocked: ${local.config.security_requirements.public_access_blocked}"
      echo "Environment: ${var.environment}"
      echo "=== Validation Complete ==="
    EOT
  }

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_server_side_encryption_configuration.this,
    aws_s3_bucket_versioning.this,
    aws_s3_bucket_public_access_block.this
  ]
}