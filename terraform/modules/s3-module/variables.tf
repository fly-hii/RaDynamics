# Terraform AWS S3 Module - Variables
# Comprehensive variable definitions for S3 module

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must follow AWS naming conventions."
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
# VERSIONING CONFIGURATION
# ============================================================================

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "versioning_status" {
  description = "Versioning state of the bucket"
  type        = string
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning_status)
    error_message = "Versioning status must be one of: Enabled, Suspended, Disabled."
  }
}

variable "enable_mfa_delete" {
  description = "Enable MFA delete for the S3 bucket"
  type        = bool
  default     = false
}

variable "mfa_delete_status" {
  description = "MFA delete status for the bucket"
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.mfa_delete_status)
    error_message = "MFA delete status must be either 'Enabled' or 'Disabled'."
  }
}

# ============================================================================
# ENCRYPTION CONFIGURATION
# ============================================================================

variable "require_encryption" {
  description = "Whether to require encryption for all objects"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_type)
    error_message = "Encryption type must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (required if encryption_type is aws:kms)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether to use S3 bucket keys for KMS encryption"
  type        = bool
  default     = true
}

# ============================================================================
# PUBLIC ACCESS CONFIGURATION
# ============================================================================

variable "block_public_access" {
  description = "Whether to block all public access to the bucket"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether to block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether to block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether to restrict public bucket policies"
  type        = bool
  default     = true
}

# ============================================================================
# BUCKET POLICY CONFIGURATION
# ============================================================================

variable "bucket_policy" {
  description = "JSON policy document for the bucket"
  type        = string
  default     = null
}

variable "enable_ssl_only" {
  description = "Whether to enforce SSL-only access to the bucket"
  type        = bool
  default     = true
}

# ============================================================================
# ACCESS LOGGING CONFIGURATION
# ============================================================================

variable "enable_access_logging" {
  description = "Enable access logging for the S3 bucket"
  type        = bool
  default     = false
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

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
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
# TRANSFER ACCELERATION
# ============================================================================

variable "enable_transfer_acceleration" {
  description = "Enable transfer acceleration"
  type        = bool
  default     = false
}

# ============================================================================
# REQUESTER PAYS
# ============================================================================

variable "enable_requester_pays" {
  description = "Enable requester pays"
  type        = bool
  default     = false
}

# ============================================================================
# OBJECT LOCK CONFIGURATION
# ============================================================================

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
  validation {
    condition     = var.object_lock_retention_days >= 1 && var.object_lock_retention_days <= 36500
    error_message = "Object lock retention days must be between 1 and 36500."
  }
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
  default     = false
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
# MONITORING CONFIGURATION
# ============================================================================

variable "enable_cloudwatch_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of alarm actions (SNS topic ARNs)"
  type        = list(string)
  default     = []
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

variable "enable_security_validation" {
  description = "Enable security validation checks"
  type        = bool
  default     = true
}

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
  default     = "s3-project"
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
  default     = "s3-application"
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