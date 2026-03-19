# Terraform AWS S3 Module - Outputs
# L1 Module outputs following CCMS standards

#------------------------------------------------------------------------------
# BUCKET OUTPUTS
#------------------------------------------------------------------------------

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for the S3 bucket"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "bucket_region" {
  description = "AWS region where the S3 bucket is located"
  value       = aws_s3_bucket.this.region
}

#------------------------------------------------------------------------------
# VERSIONING OUTPUTS
#------------------------------------------------------------------------------

output "versioning_configuration" {
  description = "Versioning configuration of the S3 bucket"
  value = {
    status     = aws_s3_bucket_versioning.this.versioning_configuration[0].status
    mfa_delete = aws_s3_bucket_versioning.this.versioning_configuration[0].mfa_delete
  }
}

#------------------------------------------------------------------------------
# ENCRYPTION OUTPUTS
#------------------------------------------------------------------------------

output "encryption_configuration" {
  description = "Server-side encryption configuration"
  value = var.require_encryption ? {
    sse_algorithm     = try(tolist(aws_s3_bucket_server_side_encryption_configuration.this[0].rule)[0].apply_server_side_encryption_by_default[0].sse_algorithm, null)
    kms_master_key_id = try(tolist(aws_s3_bucket_server_side_encryption_configuration.this[0].rule)[0].apply_server_side_encryption_by_default[0].kms_master_key_id, null)
    bucket_key_enabled = try(tolist(aws_s3_bucket_server_side_encryption_configuration.this[0].rule)[0].bucket_key_enabled, null)
  } : null
}

#------------------------------------------------------------------------------
# PUBLIC ACCESS OUTPUTS
#------------------------------------------------------------------------------

output "public_access_block" {
  description = "Public access block configuration"
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.this.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.this.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.this.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.this.restrict_public_buckets
  }
}

#------------------------------------------------------------------------------
# POLICY OUTPUTS
#------------------------------------------------------------------------------

output "bucket_policy" {
  description = "Bucket policy document"
  value       = var.bucket_policy != null || var.enable_ssl_only ? aws_s3_bucket_policy.this[0].policy : null
}

#------------------------------------------------------------------------------
# LOGGING OUTPUTS
#------------------------------------------------------------------------------

output "access_logging" {
  description = "Access logging configuration"
  value = var.enable_access_logging && var.access_log_bucket != null ? {
    target_bucket = aws_s3_bucket_logging.this[0].target_bucket
    target_prefix = aws_s3_bucket_logging.this[0].target_prefix
  } : null
}

#------------------------------------------------------------------------------
# LIFECYCLE OUTPUTS
#------------------------------------------------------------------------------

output "lifecycle_configuration" {
  description = "Lifecycle configuration rules"
  value = length(var.lifecycle_rules) > 0 ? {
    rules_count = length(var.lifecycle_rules)
    rules = [
      for rule in aws_s3_bucket_lifecycle_configuration.this[0].rule : {
        id     = rule.id
        status = rule.status
      }
    ]
  } : null
}

#------------------------------------------------------------------------------
# CORS OUTPUTS
#------------------------------------------------------------------------------

output "cors_configuration" {
  description = "CORS configuration rules"
  value = length(var.cors_rules) > 0 ? {
    rules_count = length(var.cors_rules)
    rules = [
      for rule in aws_s3_bucket_cors_configuration.this[0].cors_rule : {
        allowed_methods = rule.allowed_methods
        allowed_origins = rule.allowed_origins
      }
    ]
  } : null
}

#------------------------------------------------------------------------------
# WEBSITE HOSTING OUTPUTS
#------------------------------------------------------------------------------

output "website_configuration" {
  description = "Website hosting configuration"
  value = var.enable_website_hosting ? {
    website_endpoint = aws_s3_bucket_website_configuration.this[0].website_endpoint
    website_domain   = aws_s3_bucket_website_configuration.this[0].website_domain
    index_document   = aws_s3_bucket_website_configuration.this[0].index_document[0].suffix
    error_document   = aws_s3_bucket_website_configuration.this[0].error_document[0].key
  } : null
}

#------------------------------------------------------------------------------
# TRANSFER ACCELERATION OUTPUTS
#------------------------------------------------------------------------------

output "transfer_acceleration" {
  description = "Transfer acceleration configuration"
  value = var.enable_transfer_acceleration ? {
    status                = aws_s3_bucket_accelerate_configuration.this[0].status
    acceleration_endpoint = "${aws_s3_bucket.this.id}.s3-accelerate.amazonaws.com"
  } : null
}

#------------------------------------------------------------------------------
# OBJECT LOCK OUTPUTS
#------------------------------------------------------------------------------

output "object_lock_configuration" {
  description = "Object lock configuration"
  value = var.enable_object_lock ? {
    mode           = aws_s3_bucket_object_lock_configuration.this[0].rule[0].default_retention[0].mode
    retention_days = aws_s3_bucket_object_lock_configuration.this[0].rule[0].default_retention[0].days
  } : null
}

#------------------------------------------------------------------------------
# NOTIFICATION OUTPUTS
#------------------------------------------------------------------------------

output "notification_configuration" {
  description = "Notification configuration"
  value = length(var.notification_configurations) > 0 ? {
    configurations_count = length(var.notification_configurations)
    lambda_functions = [
      for config in var.notification_configurations : {
        destination_arn = config.destination_arn
        events         = config.events
      } if config.type == "lambda"
    ]
    sns_topics = [
      for config in var.notification_configurations : {
        destination_arn = config.destination_arn
        events         = config.events
      } if config.type == "sns"
    ]
    sqs_queues = [
      for config in var.notification_configurations : {
        destination_arn = config.destination_arn
        events         = config.events
      } if config.type == "sqs"
    ]
  } : null
}

#------------------------------------------------------------------------------
# INTELLIGENT TIERING OUTPUTS
#------------------------------------------------------------------------------

output "intelligent_tiering" {
  description = "Intelligent tiering configuration"
  value = var.enable_intelligent_tiering ? {
    name   = aws_s3_bucket_intelligent_tiering_configuration.this[0].name
    status = aws_s3_bucket_intelligent_tiering_configuration.this[0].status
    prefix = aws_s3_bucket_intelligent_tiering_configuration.this[0].filter[0].prefix
  } : null
}

#------------------------------------------------------------------------------
# MONITORING OUTPUTS
#------------------------------------------------------------------------------

output "cloudwatch_monitoring" {
  description = "CloudWatch monitoring configuration"
  value = var.enable_cloudwatch_monitoring ? {
    metric_filter = {
      name           = aws_cloudwatch_log_metric_filter.s3_access_denied[0].name
      log_group_name = aws_cloudwatch_log_metric_filter.s3_access_denied[0].log_group_name
    }
    alarm = {
      name = aws_cloudwatch_metric_alarm.s3_access_denied[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.s3_access_denied[0].arn
    }
  } : null
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS (CCMS COMPLIANCE)
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the bucket including default provider tags"
  value       = aws_s3_bucket.this.tags_all
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

#------------------------------------------------------------------------------
# SECURITY CONTROL OUTPUTS
#------------------------------------------------------------------------------

output "security_controls_status" {
  description = "Status of implemented security controls"
  value = {
    s3_01_encryption = {
      control = "Server-Side Encryption"
      status  = var.require_encryption ? "ENABLED" : "DISABLED"
      details = "Bucket encryption configuration status"
    }
    s3_02_versioning = {
      control = "Object Versioning"
      status  = var.enable_versioning ? "ENABLED" : "DISABLED"
      details = "Object versioning and MFA delete status"
    }
    s3_03_public_access = {
      control = "Public Access Block"
      status  = var.block_public_access ? "BLOCKED" : "ALLOWED"
      details = "Public access prevention status"
    }
    s3_04_ssl_only = {
      control = "SSL-Only Access"
      status  = var.enable_ssl_only ? "ENFORCED" : "OPTIONAL"
      details = "HTTPS-only access enforcement"
    }
    s3_05_access_logging = {
      control = "Access Logging"
      status  = var.enable_access_logging && var.access_log_bucket != null ? "ENABLED" : "DISABLED"
      details = "S3 access logging configuration"
    }
    s3_06_lifecycle_management = {
      control = "Lifecycle Management"
      status  = length(var.lifecycle_rules) > 0 ? "CONFIGURED" : "NOT_CONFIGURED"
      details = "Object lifecycle and cost optimization"
    }
    s3_07_object_lock = {
      control = "Object Lock"
      status  = var.enable_object_lock ? "ENABLED" : "DISABLED"
      details = "Object immutability and compliance"
    }
    s3_08_monitoring = {
      control = "CloudWatch Monitoring"
      status  = var.enable_cloudwatch_monitoring ? "ENABLED" : "DISABLED"
      details = "Security monitoring and alerting"
    }
  }
}

output "security_compliance_tags" {
  description = "Security compliance tags applied to the bucket"
  value = {
    encryption_enabled    = lookup(local.standard_tags, "security:encryption", "")
    versioning_enabled    = lookup(local.standard_tags, "security:versioning", "")
    public_access_blocked = lookup(local.standard_tags, "security:public-access", "")
    mfa_delete_enabled    = lookup(local.standard_tags, "security:mfa-delete", "")
    logging_enabled       = lookup(local.standard_tags, "security:logging", "")
    compliance_ccms       = lookup(local.standard_tags, "compliance:ccms", "")
    data_classification   = lookup(local.standard_tags, "compliance:data-class", "")
    retention_policy      = lookup(local.standard_tags, "compliance:retention", "")
  }
}

output "encryption_details" {
  description = "Detailed encryption configuration"
  value = var.require_encryption ? {
    algorithm         = var.encryption_type
    kms_key_id       = var.kms_key_id
    bucket_key_enabled = var.bucket_key_enabled
    kms_key_arn      = local.kms_key_arn
  } : null
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "bucket_configuration_summary" {
  description = "Summary of bucket configuration"
  value = {
    bucket_name               = aws_s3_bucket.this.id
    environment              = var.environment
    versioning_enabled       = var.enable_versioning
    encryption_enabled       = var.require_encryption
    public_access_blocked    = var.block_public_access
    ssl_only_enforced        = var.enable_ssl_only
    access_logging_enabled   = var.enable_access_logging && var.access_log_bucket != null
    lifecycle_rules_count    = length(var.lifecycle_rules)
    cors_rules_count         = length(var.cors_rules)
    website_hosting_enabled  = var.enable_website_hosting
    transfer_acceleration    = var.enable_transfer_acceleration
    object_lock_enabled      = var.enable_object_lock
    intelligent_tiering      = var.enable_intelligent_tiering
    cloudwatch_monitoring    = var.enable_cloudwatch_monitoring
  }
}

output "compliance_status" {
  description = "Overall compliance status"
  value = {
    ccms_compliant = var.require_encryption && var.enable_versioning && var.block_public_access
    security_score = (
      (var.require_encryption ? 1 : 0) +
      (var.enable_versioning ? 1 : 0) +
      (var.block_public_access ? 1 : 0) +
      (var.enable_ssl_only ? 1 : 0) +
      (var.enable_access_logging && var.access_log_bucket != null ? 1 : 0) +
      (length(var.lifecycle_rules) > 0 ? 1 : 0) +
      (var.enable_object_lock ? 1 : 0) +
      (var.enable_cloudwatch_monitoring ? 1 : 0)
    )
    max_security_score = 8
    environment_requirements_met = var.environment == "prod" ? (
      var.require_encryption && var.enable_versioning && var.block_public_access && var.enable_ssl_only
    ) : true
  }
}