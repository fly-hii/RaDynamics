# Terraform AWS S3 Enhanced Module - Variables
# L2 Module variables with advanced features

# ============================================================================
# BASIC CONFIGURATION
# ============================================================================

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, test, staging, prod."
  }
}

variable "compliance_mode" {
  description = "Compliance mode for enhanced security controls"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "strict", "regulatory"], var.compliance_mode)
    error_message = "Compliance mode must be one of: standard, strict, regulatory."
  }
}

variable "force_destroy" {
  description = "Allow the bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "prevent_destroy" {
  description = "Prevent the bucket from being destroyed"
  type        = bool
  default     = true
}

# ============================================================================
# ENCRYPTION CONFIGURATION
# ============================================================================

variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "aws:kms"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_type)
    error_message = "Encryption type must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether to use S3 bucket keys for KMS encryption"
  type        = bool
  default     = true
}

# ============================================================================
# ACCESS LOGGING CONFIGURATION
# ============================================================================

variable "enable_access_logging" {
  description = "Enable access logging for the S3 bucket"
  type        = bool
  default     = true
}

variable "access_log_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = null
}

# ============================================================================
# LIFECYCLE CONFIGURATION
# ============================================================================

variable "enable_default_lifecycle" {
  description = "Enable default lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

variable "transition_to_ia_days" {
  description = "Days after which objects transition to Standard-IA"
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Days after which objects transition to Glacier"
  type        = number
  default     = 90
}

variable "transition_to_deep_archive_days" {
  description = "Days after which objects transition to Deep Archive"
  type        = number
  default     = 365
}

variable "noncurrent_version_transition_days" {
  description = "Days after which noncurrent versions transition to Standard-IA"
  type        = number
  default     = 30
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent versions expire"
  type        = number
  default     = 90
}

variable "multipart_upload_cleanup_days" {
  description = "Days after which incomplete multipart uploads are cleaned up"
  type        = number
  default     = 7
}

variable "custom_lifecycle_rules" {
  description = "Additional custom lifecycle rules"
  type = list(object({
    id     = string
    status = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))
  default = []
}

# ============================================================================
# CORS CONFIGURATION
# ============================================================================

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

# ============================================================================
# WEBSITE HOSTING CONFIGURATION
# ============================================================================

variable "enable_website_hosting" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "Index document for website hosting"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Error document for website hosting"
  type        = string
  default     = "error.html"
}

# ============================================================================
# ADVANCED FEATURES
# ============================================================================

variable "enable_transfer_acceleration" {
  description = "Enable transfer acceleration"
  type        = bool
  default     = false
}

variable "enable_requester_pays" {
  description = "Enable requester pays"
  type        = bool
  default     = false
}

variable "enable_object_lock" {
  description = "Enable object lock"
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Object lock retention mode"
  type        = string
  default     = "GOVERNANCE"
  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_mode)
    error_message = "Object lock mode must be either 'GOVERNANCE' or 'COMPLIANCE'."
  }
}

variable "object_lock_retention_days" {
  description = "Object lock retention period in days"
  type        = number
  default     = 365
}

# ============================================================================
# NOTIFICATION CONFIGURATION
# ============================================================================

variable "notification_configurations" {
  description = "List of notification configurations"
  type = list(object({
    type            = string # lambda, sns, sqs
    destination_arn = string
    events          = list(string)
    filter_prefix   = optional(string)
    filter_suffix   = optional(string)
  }))
  default = []
}

# ============================================================================
# INTELLIGENT TIERING
# ============================================================================

variable "enable_intelligent_tiering" {
  description = "Enable intelligent tiering"
  type        = bool
  default     = true
}

variable "intelligent_tiering_prefix" {
  description = "Prefix for intelligent tiering"
  type        = string
  default     = ""
}

variable "intelligent_tiering_tags" {
  description = "Tags for intelligent tiering filter"
  type        = map(string)
  default     = {}
}

variable "intelligent_tiering_deep_archive_days" {
  description = "Days after which objects move to deep archive"
  type        = number
  default     = 180
}

# ============================================================================
# CROSS-REGION REPLICATION
# ============================================================================

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_destination_bucket" {
  description = "Destination bucket ARN for replication"
  type        = string
  default     = null
}

variable "replication_storage_class" {
  description = "Storage class for replicated objects"
  type        = string
  default     = "STANDARD_IA"
  validation {
    condition = contains([
      "STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", 
      "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE"
    ], var.replication_storage_class)
    error_message = "Invalid replication storage class."
  }
}

variable "replication_kms_key_id" {
  description = "KMS key ID for replication encryption"
  type        = string
  default     = null
}

# ============================================================================
# ANALYTICS CONFIGURATION
# ============================================================================

variable "enable_analytics" {
  description = "Enable S3 analytics"
  type        = bool
  default     = false
}

variable "analytics_prefix" {
  description = "Prefix for analytics filter"
  type        = string
  default     = ""
}

variable "analytics_tags" {
  description = "Tags for analytics filter"
  type        = map(string)
  default     = {}
}

variable "analytics_destination_bucket" {
  description = "Destination bucket ARN for analytics export"
  type        = string
  default     = null
}

variable "analytics_export_prefix" {
  description = "Prefix for analytics export"
  type        = string
  default     = "analytics/"
}

# ============================================================================
# INVENTORY CONFIGURATION
# ============================================================================

variable "enable_inventory" {
  description = "Enable S3 inventory"
  type        = bool
  default     = false
}

variable "inventory_frequency" {
  description = "Inventory generation frequency"
  type        = string
  default     = "Daily"
  validation {
    condition     = contains(["Daily", "Weekly"], var.inventory_frequency)
    error_message = "Inventory frequency must be either 'Daily' or 'Weekly'."
  }
}

variable "inventory_format" {
  description = "Inventory file format"
  type        = string
  default     = "CSV"
  validation {
    condition     = contains(["CSV", "ORC", "Parquet"], var.inventory_format)
    error_message = "Inventory format must be one of: CSV, ORC, Parquet."
  }
}

variable "inventory_destination_bucket" {
  description = "Destination bucket ARN for inventory"
  type        = string
  default     = null
}

variable "inventory_prefix" {
  description = "Prefix for inventory files"
  type        = string
  default     = "inventory/"
}

variable "inventory_kms_key_id" {
  description = "KMS key ID for inventory encryption"
  type        = string
  default     = null
}

variable "inventory_optional_fields" {
  description = "Optional fields to include in inventory"
  type        = list(string)
  default = [
    "Size", "LastModifiedDate", "StorageClass", 
    "ETag", "IsMultipartUploaded", "ReplicationStatus"
  ]
}

# ============================================================================
# BACKUP CONFIGURATION
# ============================================================================

variable "enable_backup" {
  description = "Enable AWS Backup for the S3 bucket"
  type        = bool
  default     = false
}

variable "backup_schedule" {
  description = "Backup schedule in cron format"
  type        = string
  default     = "cron(0 2 ? * * *)" # Daily at 2 AM
}

variable "backup_kms_key_id" {
  description = "KMS key ID for backup encryption"
  type        = string
  default     = null
}

variable "backup_cold_storage_after" {
  description = "Days after which backups move to cold storage"
  type        = number
  default     = 30
}

variable "backup_delete_after" {
  description = "Days after which backups are deleted"
  type        = number
  default     = 365
}

# ============================================================================
# MONITORING CONFIGURATION
# ============================================================================

variable "enable_cloudwatch_monitoring" {
  description = "Enable basic CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "enable_enhanced_monitoring" {
  description = "Enable enhanced CloudWatch monitoring with dashboard"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of alarm actions (SNS topic ARNs)"
  type        = list(string)
  default     = []
}

variable "bucket_size_alarm_threshold" {
  description = "Bucket size alarm threshold in bytes"
  type        = number
  default     = 107374182400 # 100 GB
}

variable "object_count_alarm_threshold" {
  description = "Object count alarm threshold"
  type        = number
  default     = 1000000 # 1 million objects
}

# ============================================================================
# BUCKET POLICY
# ============================================================================

variable "custom_bucket_policy" {
  description = "Custom bucket policy JSON document"
  type        = string
  default     = null
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

variable "retention_policy" {
  description = "Data retention policy classification"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["short-term", "standard", "long-term", "permanent"], var.retention_policy)
    error_message = "Retention policy must be one of: short-term, standard, long-term, permanent."
  }
}

# ============================================================================
# CCMS COMPLIANCE VARIABLES
# ============================================================================

variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "default-cost-center"
}

variable "project_name" {
  description = "Project name for resource organization"
  type        = string
  default     = "s3-enhanced-project"
}

variable "owner" {
  description = "Resource owner for accountability"
  type        = string
  default     = "terraform-user"
}

variable "business_unit" {
  description = "Business unit responsible for the resource"
  type        = string
  default     = "engineering"
}

variable "application_name" {
  description = "Application name for resource categorization"
  type        = string
  default     = "s3-enhanced-application"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "additional_tags" {
  description = "Additional tags to be merged with core tags"
  type        = map(string)
  default     = {}
}