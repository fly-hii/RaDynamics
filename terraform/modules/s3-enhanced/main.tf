# Terraform AWS S3 Enhanced Module - Main Configuration
# L2 Module for S3 Bucket provisioning with advanced features and integrations

# Local implementation of enhanced configuration
locals {
  # Enhanced security requirements
  enhanced_security = {
    encryption_required       = true
    versioning_required      = true
    mfa_delete_required      = var.environment == "prod" ? true : false
    public_access_blocked    = true
    ssl_only_required        = true
    access_logging_required  = var.environment == "prod" ? true : false
    lifecycle_required       = true
    monitoring_required      = var.environment == "prod" ? true : false
    object_lock_required     = var.compliance_mode == "strict" ? true : false
  }

  # Enhanced tagging with additional metadata
  enhanced_tags = {
    Module           = "terraform-aws-l2-s3-enhanced"
    Tier            = "L2"
    SecurityLevel   = "enhanced"
    ComplianceMode  = var.compliance_mode
    BackupEnabled   = var.enable_backup ? "true" : "false"
    ReplicationEnabled = var.enable_cross_region_replication ? "true" : "false"
    AnalyticsEnabled = var.enable_analytics ? "true" : "false"
  }

  # Default lifecycle rules for enhanced module
  default_lifecycle_rules = var.enable_default_lifecycle ? [
    {
      id     = "default-lifecycle-rule"
      status = "Enabled"
      filter = {
        prefix = ""
      }
      transitions = [
        {
          days          = var.transition_to_ia_days
          storage_class = "STANDARD_IA"
        },
        {
          days          = var.transition_to_glacier_days
          storage_class = "GLACIER"
        },
        {
          days          = var.transition_to_deep_archive_days
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      noncurrent_version_transitions = [
        {
          noncurrent_days = var.noncurrent_version_transition_days
          storage_class   = "STANDARD_IA"
        }
      ]
      noncurrent_version_expiration = {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
      abort_incomplete_multipart_upload = {
        days_after_initiation = var.multipart_upload_cleanup_days
      }
    }
  ] : []

  # Merge custom lifecycle rules with defaults
  all_lifecycle_rules = concat(local.default_lifecycle_rules, var.custom_lifecycle_rules)
}

# ============================================================================
# PRIMARY S3 BUCKET USING L1 MODULE
# ============================================================================

module "s3_bucket" {
  source = "../s3-module"

  # Basic configuration
  bucket_name     = var.bucket_name
  environment     = var.environment
  force_destroy   = var.force_destroy
  prevent_destroy = var.prevent_destroy

  # Enhanced security configuration
  require_encryption    = local.enhanced_security.encryption_required
  encryption_type      = var.encryption_type
  kms_key_id          = var.kms_key_id
  bucket_key_enabled   = var.bucket_key_enabled

  enable_versioning    = local.enhanced_security.versioning_required
  versioning_status    = "Enabled"
  enable_mfa_delete    = local.enhanced_security.mfa_delete_required
  mfa_delete_status    = local.enhanced_security.mfa_delete_required ? "Enabled" : "Disabled"

  block_public_access  = local.enhanced_security.public_access_blocked
  enable_ssl_only      = local.enhanced_security.ssl_only_required
  bucket_policy        = var.custom_bucket_policy

  # Access logging
  enable_access_logging = local.enhanced_security.access_logging_required || var.enable_access_logging
  access_log_bucket    = var.access_log_bucket
  access_log_prefix    = var.access_log_prefix

  # Lifecycle management
  lifecycle_rules = local.all_lifecycle_rules

  # CORS configuration
  cors_rules = var.cors_rules

  # Website hosting
  enable_website_hosting   = var.enable_website_hosting
  website_index_document  = var.website_index_document
  website_error_document  = var.website_error_document

  # Advanced features
  enable_transfer_acceleration = var.enable_transfer_acceleration
  enable_requester_pays       = var.enable_requester_pays
  enable_object_lock          = local.enhanced_security.object_lock_required || var.enable_object_lock
  object_lock_mode            = var.object_lock_mode
  object_lock_retention_days  = var.object_lock_retention_days

  # Notifications
  notification_configurations = var.notification_configurations

  # Intelligent tiering
  enable_intelligent_tiering           = var.enable_intelligent_tiering
  intelligent_tiering_prefix          = var.intelligent_tiering_prefix
  intelligent_tiering_tags            = var.intelligent_tiering_tags
  intelligent_tiering_deep_archive_days = var.intelligent_tiering_deep_archive_days

  # Monitoring
  enable_cloudwatch_monitoring = local.enhanced_security.monitoring_required || var.enable_cloudwatch_monitoring
  alarm_actions               = var.alarm_actions

  # Security validation
  enable_security_validation = true
  retention_policy          = var.retention_policy

  # CCMS compliance
  cost_center         = var.cost_center
  project_name        = var.project_name
  owner              = var.owner
  business_unit      = var.business_unit
  application_name   = var.application_name
  data_classification = var.data_classification

  # Enhanced tags
  additional_tags = merge(local.enhanced_tags, var.additional_tags)
}

# ============================================================================
# CROSS-REGION REPLICATION (OPTIONAL)
# ============================================================================

resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.enable_cross_region_replication ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = module.s3_bucket.bucket_id

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = var.replication_destination_bucket
      storage_class = var.replication_storage_class

      dynamic "encryption_configuration" {
        for_each = var.replication_kms_key_id != null ? [1] : []
        content {
          replica_kms_key_id = var.replication_kms_key_id
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.replication_versioning]
}

# Enable versioning on destination bucket if replication is enabled
resource "aws_s3_bucket_versioning" "replication_versioning" {
  count  = var.enable_cross_region_replication ? 1 : 0
  bucket = var.replication_destination_bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0

  name = "${var.bucket_name}-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.enhanced_tags, var.additional_tags)
}

resource "aws_iam_policy" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0

  name = "${var.bucket_name}-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${module.s3_bucket.bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = module.s3_bucket.bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${var.replication_destination_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

# ============================================================================
# S3 ANALYTICS CONFIGURATION
# ============================================================================

resource "aws_s3_bucket_analytics_configuration" "this" {
  count  = var.enable_analytics ? 1 : 0
  bucket = module.s3_bucket.bucket_id
  name   = "${var.bucket_name}-analytics"

  filter {
    prefix = var.analytics_prefix
    tags   = var.analytics_tags
  }

  storage_class_analysis {
    data_export {
      destination {
        s3_bucket_destination {
          bucket_arn = var.analytics_destination_bucket
          prefix     = var.analytics_export_prefix
          format     = "CSV"
        }
      }
      output_schema_version = "V_1"
    }
  }
}

# ============================================================================
# S3 INVENTORY CONFIGURATION
# ============================================================================

resource "aws_s3_bucket_inventory" "this" {
  count  = var.enable_inventory ? 1 : 0
  bucket = module.s3_bucket.bucket_id
  name   = "${var.bucket_name}-inventory"

  included_object_versions = "All"
  schedule {
    frequency = var.inventory_frequency
  }

  destination {
    bucket {
      format     = var.inventory_format
      bucket_arn = var.inventory_destination_bucket
      prefix     = var.inventory_prefix

      dynamic "encryption" {
        for_each = var.inventory_kms_key_id != null ? [1] : []
        content {
          sse_kms {
            key_id = var.inventory_kms_key_id
          }
        }
      }
    }
  }

  optional_fields = var.inventory_optional_fields
}

# ============================================================================
# BACKUP CONFIGURATION (AWS BACKUP)
# ============================================================================

resource "aws_backup_vault" "s3" {
  count       = var.enable_backup ? 1 : 0
  name        = "${var.bucket_name}-backup-vault"
  kms_key_arn = var.backup_kms_key_id

  tags = merge(local.enhanced_tags, var.additional_tags)
}

resource "aws_backup_plan" "s3" {
  count = var.enable_backup ? 1 : 0
  name  = "${var.bucket_name}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.s3[0].name
    schedule          = var.backup_schedule

    lifecycle {
      cold_storage_after = var.backup_cold_storage_after
      delete_after       = var.backup_delete_after
    }

    recovery_point_tags = merge(local.enhanced_tags, var.additional_tags)
  }

  tags = merge(local.enhanced_tags, var.additional_tags)
}

resource "aws_iam_role" "backup" {
  count = var.enable_backup ? 1 : 0
  name  = "${var.bucket_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.enhanced_tags, var.additional_tags)
}

resource "aws_iam_role_policy_attachment" "backup" {
  count = var.enable_backup ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForS3Backup"
}

resource "aws_backup_selection" "s3" {
  count        = var.enable_backup ? 1 : 0
  iam_role_arn = aws_iam_role.backup[0].arn
  name         = "${var.bucket_name}-backup-selection"
  plan_id      = aws_backup_plan.s3[0].id

  resources = [
    module.s3_bucket.bucket_arn
  ]
}

# ============================================================================
# ENHANCED CLOUDWATCH MONITORING
# ============================================================================

# Custom CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "s3" {
  count          = var.enable_enhanced_monitoring ? 1 : 0
  dashboard_name = "${var.bucket_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", module.s3_bucket.bucket_id, "StorageType", "StandardStorage"],
            [".", "NumberOfObjects", ".", ".", ".", "AllStorageTypes"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "S3 Bucket Metrics"
          period  = 300
        }
      }
    ]
  })
}

# Data source for current region
data "aws_region" "current" {}

# Additional CloudWatch Alarms for enhanced monitoring
resource "aws_cloudwatch_metric_alarm" "bucket_size" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  alarm_name          = "${var.bucket_name}-bucket-size-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400" # Daily
  statistic           = "Average"
  threshold           = var.bucket_size_alarm_threshold
  alarm_description   = "This metric monitors S3 bucket size"
  alarm_actions       = var.alarm_actions

  dimensions = {
    BucketName  = module.s3_bucket.bucket_id
    StorageType = "StandardStorage"
  }

  tags = merge(local.enhanced_tags, var.additional_tags)
}

resource "aws_cloudwatch_metric_alarm" "object_count" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  alarm_name          = "${var.bucket_name}-object-count-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = "86400" # Daily
  statistic           = "Average"
  threshold           = var.object_count_alarm_threshold
  alarm_description   = "This metric monitors S3 object count"
  alarm_actions       = var.alarm_actions

  dimensions = {
    BucketName  = module.s3_bucket.bucket_id
    StorageType = "AllStorageTypes"
  }

  tags = merge(local.enhanced_tags, var.additional_tags)
}