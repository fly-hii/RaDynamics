# Terraform AWS S3 Enhanced Module - Outputs
# L2 Module outputs with enhanced features

#------------------------------------------------------------------------------
# L1 MODULE OUTPUTS (PASSTHROUGH)
#------------------------------------------------------------------------------

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_bucket.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for the S3 bucket"
  value       = module.s3_bucket.bucket_hosted_zone_id
}

output "bucket_region" {
  description = "AWS region where the S3 bucket is located"
  value       = module.s3_bucket.bucket_region
}

output "versioning_configuration" {
  description = "Versioning configuration of the S3 bucket"
  value       = module.s3_bucket.versioning_configuration
}

output "encryption_configuration" {
  description = "Server-side encryption configuration"
  value       = module.s3_bucket.encryption_configuration
}

output "public_access_block" {
  description = "Public access block configuration"
  value       = module.s3_bucket.public_access_block
}

output "bucket_policy" {
  description = "Bucket policy document"
  value       = module.s3_bucket.bucket_policy
}

output "security_controls_status" {
  description = "Status of implemented security controls from L1 module"
  value       = module.s3_bucket.security_controls_status
}

output "compliance_status" {
  description = "Overall compliance status from L1 module"
  value       = module.s3_bucket.compliance_status
}

#------------------------------------------------------------------------------
# ENHANCED FEATURES OUTPUTS
#------------------------------------------------------------------------------

output "enhanced_features_status" {
  description = "Status of enhanced L2 features"
  value = {
    cross_region_replication = {
      enabled = var.enable_cross_region_replication
      destination_bucket = var.replication_destination_bucket
      storage_class = var.replication_storage_class
      replication_role_arn = var.enable_cross_region_replication ? aws_iam_role.replication[0].arn : null
    }
    analytics = {
      enabled = var.enable_analytics
      destination_bucket = var.analytics_destination_bucket
      export_prefix = var.analytics_export_prefix
    }
    inventory = {
      enabled = var.enable_inventory
      frequency = var.inventory_frequency
      format = var.inventory_format
      destination_bucket = var.inventory_destination_bucket
    }
    backup = {
      enabled = var.enable_backup
      schedule = var.backup_schedule
      vault_arn = var.enable_backup ? aws_backup_vault.s3[0].arn : null
      plan_arn = var.enable_backup ? aws_backup_plan.s3[0].arn : null
    }
    enhanced_monitoring = {
      enabled = var.enable_enhanced_monitoring
      dashboard_name = var.enable_enhanced_monitoring ? aws_cloudwatch_dashboard.s3[0].dashboard_name : null
    }
  }
}

#------------------------------------------------------------------------------
# CROSS-REGION REPLICATION OUTPUTS
#------------------------------------------------------------------------------

output "replication_configuration" {
  description = "Cross-region replication configuration"
  value = var.enable_cross_region_replication ? {
    role_arn = aws_iam_role.replication[0].arn
    destination_bucket = var.replication_destination_bucket
    storage_class = var.replication_storage_class
    kms_key_id = var.replication_kms_key_id
    status = "Enabled"
  } : null
}

output "replication_iam_role" {
  description = "IAM role for cross-region replication"
  value = var.enable_cross_region_replication ? {
    arn = aws_iam_role.replication[0].arn
    name = aws_iam_role.replication[0].name
    policy_arn = aws_iam_policy.replication[0].arn
  } : null
}

#------------------------------------------------------------------------------
# ANALYTICS OUTPUTS
#------------------------------------------------------------------------------

output "analytics_configuration" {
  description = "S3 analytics configuration"
  value = var.enable_analytics ? {
    name = aws_s3_bucket_analytics_configuration.this[0].name
    prefix = var.analytics_prefix
    tags = var.analytics_tags
    destination_bucket = var.analytics_destination_bucket
    export_prefix = var.analytics_export_prefix
  } : null
}

#------------------------------------------------------------------------------
# INVENTORY OUTPUTS
#------------------------------------------------------------------------------

output "inventory_configuration" {
  description = "S3 inventory configuration"
  value = var.enable_inventory ? {
    name = aws_s3_bucket_inventory.this[0].name
    frequency = var.inventory_frequency
    format = var.inventory_format
    destination_bucket = var.inventory_destination_bucket
    prefix = var.inventory_prefix
    optional_fields = var.inventory_optional_fields
    kms_key_id = var.inventory_kms_key_id
  } : null
}

#------------------------------------------------------------------------------
# BACKUP OUTPUTS
#------------------------------------------------------------------------------

output "backup_configuration" {
  description = "AWS Backup configuration"
  value = var.enable_backup ? {
    vault = {
      arn = aws_backup_vault.s3[0].arn
      name = aws_backup_vault.s3[0].name
      kms_key_arn = var.backup_kms_key_id
    }
    plan = {
      arn = aws_backup_plan.s3[0].arn
      name = aws_backup_plan.s3[0].name
      schedule = var.backup_schedule
    }
    role = {
      arn = aws_iam_role.backup[0].arn
      name = aws_iam_role.backup[0].name
    }
    selection = {
      name = aws_backup_selection.s3[0].name
      resources = [module.s3_bucket.bucket_arn]
    }
    lifecycle = {
      cold_storage_after = var.backup_cold_storage_after
      delete_after = var.backup_delete_after
    }
  } : null
}

#------------------------------------------------------------------------------
# ENHANCED MONITORING OUTPUTS
#------------------------------------------------------------------------------

output "enhanced_monitoring" {
  description = "Enhanced CloudWatch monitoring configuration"
  value = var.enable_enhanced_monitoring ? {
    dashboard = {
      name = aws_cloudwatch_dashboard.s3[0].dashboard_name
      url = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.s3[0].dashboard_name}"
    }
    alarms = {
      bucket_size = {
        name = aws_cloudwatch_metric_alarm.bucket_size[0].alarm_name
        arn = aws_cloudwatch_metric_alarm.bucket_size[0].arn
        threshold = var.bucket_size_alarm_threshold
      }
      object_count = {
        name = aws_cloudwatch_metric_alarm.object_count[0].alarm_name
        arn = aws_cloudwatch_metric_alarm.object_count[0].arn
        threshold = var.object_count_alarm_threshold
      }
    }
  } : null
}

#------------------------------------------------------------------------------
# LIFECYCLE MANAGEMENT OUTPUTS
#------------------------------------------------------------------------------

output "lifecycle_management" {
  description = "Lifecycle management configuration"
  value = {
    default_lifecycle_enabled = var.enable_default_lifecycle
    default_rules = var.enable_default_lifecycle ? {
      transition_to_ia_days = var.transition_to_ia_days
      transition_to_glacier_days = var.transition_to_glacier_days
      transition_to_deep_archive_days = var.transition_to_deep_archive_days
      noncurrent_version_transition_days = var.noncurrent_version_transition_days
      noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
      multipart_upload_cleanup_days = var.multipart_upload_cleanup_days
    } : null
    custom_rules_count = length(var.custom_lifecycle_rules)
    total_rules_count = length(local.all_lifecycle_rules)
  }
}

#------------------------------------------------------------------------------
# COST OPTIMIZATION OUTPUTS
#------------------------------------------------------------------------------

output "cost_optimization_features" {
  description = "Cost optimization features status"
  value = {
    intelligent_tiering = {
      enabled = var.enable_intelligent_tiering
      prefix = var.intelligent_tiering_prefix
      deep_archive_days = var.intelligent_tiering_deep_archive_days
    }
    lifecycle_rules = {
      enabled = var.enable_default_lifecycle || length(var.custom_lifecycle_rules) > 0
      rules_count = length(local.all_lifecycle_rules)
    }
    storage_class_analysis = {
      enabled = var.enable_analytics
      destination = var.analytics_destination_bucket
    }
    transfer_acceleration = {
      enabled = var.enable_transfer_acceleration
      endpoint = var.enable_transfer_acceleration ? "${module.s3_bucket.bucket_id}.s3-accelerate.amazonaws.com" : null
    }
  }
}

#------------------------------------------------------------------------------
# SECURITY ENHANCEMENT OUTPUTS
#------------------------------------------------------------------------------

output "enhanced_security_status" {
  description = "Enhanced security features status"
  value = {
    compliance_mode = var.compliance_mode
    enhanced_encryption = {
      type = var.encryption_type
      kms_key_id = var.kms_key_id
      bucket_key_enabled = var.bucket_key_enabled
    }
    object_lock = {
      enabled = var.enable_object_lock
      mode = var.object_lock_mode
      retention_days = var.object_lock_retention_days
    }
    access_logging = {
      enabled = var.enable_access_logging
      target_bucket = var.access_log_bucket
      prefix = var.access_log_prefix
    }
    replication_security = var.enable_cross_region_replication ? {
      destination_encrypted = var.replication_kms_key_id != null
      kms_key_id = var.replication_kms_key_id
    } : null
  }
}

#------------------------------------------------------------------------------
# INTEGRATION OUTPUTS
#------------------------------------------------------------------------------

output "integration_endpoints" {
  description = "Integration endpoints and ARNs"
  value = {
    bucket_arn = module.s3_bucket.bucket_arn
    bucket_domain_name = module.s3_bucket.bucket_domain_name
    website_endpoint = var.enable_website_hosting ? module.s3_bucket.website_configuration.website_endpoint : null
    transfer_acceleration_endpoint = var.enable_transfer_acceleration ? "${module.s3_bucket.bucket_id}.s3-accelerate.amazonaws.com" : null
    notification_configurations = var.notification_configurations
    backup_vault_arn = var.enable_backup ? aws_backup_vault.s3[0].arn : null
    replication_role_arn = var.enable_cross_region_replication ? aws_iam_role.replication[0].arn : null
  }
}

#------------------------------------------------------------------------------
# OPERATIONAL OUTPUTS
#------------------------------------------------------------------------------

output "operational_summary" {
  description = "Operational summary of the enhanced S3 bucket"
  value = {
    bucket_name = module.s3_bucket.bucket_id
    environment = var.environment
    compliance_mode = var.compliance_mode
    tier = "L2-Enhanced"
    
    features_enabled = {
      cross_region_replication = var.enable_cross_region_replication
      analytics = var.enable_analytics
      inventory = var.enable_inventory
      backup = var.enable_backup
      enhanced_monitoring = var.enable_enhanced_monitoring
      intelligent_tiering = var.enable_intelligent_tiering
      object_lock = var.enable_object_lock
      website_hosting = var.enable_website_hosting
      transfer_acceleration = var.enable_transfer_acceleration
    }
    
    security_features = {
      encryption_type = var.encryption_type
      versioning_enabled = true
      public_access_blocked = true
      ssl_only_enforced = true
      access_logging_enabled = var.enable_access_logging
    }
    
    cost_optimization = {
      lifecycle_rules_count = length(local.all_lifecycle_rules)
      intelligent_tiering_enabled = var.enable_intelligent_tiering
      storage_class_analysis = var.enable_analytics
    }
    
    compliance_status = {
      ccms_compliant = true
      security_controls_implemented = 8
      enhanced_features_count = (
        (var.enable_cross_region_replication ? 1 : 0) +
        (var.enable_analytics ? 1 : 0) +
        (var.enable_inventory ? 1 : 0) +
        (var.enable_backup ? 1 : 0) +
        (var.enable_enhanced_monitoring ? 1 : 0)
      )
    }
  }
}