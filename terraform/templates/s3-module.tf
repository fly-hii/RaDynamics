# AWS Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Module    = "s3-comprehensive"
    }
  }
}

# Comprehensive S3 Bucket using the enterprise module
module "s3_bucket" {
  source = "./modules/s3-module"

  # Required variables
  bucket_name = var.bucket_name
  environment = var.environment

  # Security configuration
  require_encryption    = var.require_encryption
  encryption_type      = var.encryption_type
  kms_key_id          = var.kms_key_id
  bucket_key_enabled   = var.bucket_key_enabled

  enable_versioning    = var.enable_versioning
  versioning_status    = var.versioning_status
  enable_mfa_delete    = var.enable_mfa_delete
  mfa_delete_status    = var.mfa_delete_status

  block_public_access  = var.block_public_access
  enable_ssl_only      = var.enable_ssl_only
  bucket_policy        = var.bucket_policy

  # Access logging
  enable_access_logging = var.enable_access_logging
  access_log_bucket    = var.access_log_bucket
  access_log_prefix    = var.access_log_prefix

  # Lifecycle management
  lifecycle_rules = var.lifecycle_rules

  # CORS configuration
  cors_rules = var.cors_rules

  # Website hosting
  enable_website_hosting   = var.enable_website_hosting
  website_index_document  = var.website_index_document
  website_error_document  = var.website_error_document

  # Advanced features
  enable_transfer_acceleration = var.enable_transfer_acceleration
  enable_requester_pays       = var.enable_requester_pays
  enable_object_lock          = var.enable_object_lock
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
  enable_cloudwatch_monitoring = var.enable_cloudwatch_monitoring
  alarm_actions               = var.alarm_actions

  # Security validation
  enable_security_validation = var.enable_security_validation
  retention_policy          = var.retention_policy

  # CCMS compliance
  cost_center         = var.cost_center
  project_name        = var.project_name
  owner              = var.owner
  business_unit      = var.business_unit
  application_name   = var.application_name
  data_classification = var.data_classification

  # Additional tags
  additional_tags = var.additional_tags
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "require_encryption" {
  description = "Whether to require encryption for all objects"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
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

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "versioning_status" {
  description = "Versioning state of the bucket"
  type        = string
  default     = "Enabled"
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
}

variable "block_public_access" {
  description = "Whether to block all public access to the bucket"
  type        = bool
  default     = true
}

variable "enable_ssl_only" {
  description = "Whether to enforce SSL-only access to the bucket"
  type        = bool
  default     = true
}

variable "bucket_policy" {
  description = "JSON policy document for the bucket"
  type        = string
  default     = null
}

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
}

variable "object_lock_retention_days" {
  description = "Object lock retention period in days"
  type        = number
  default     = 365
}

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

variable "enable_security_validation" {
  description = "Enable security validation checks"
  type        = bool
  default     = true
}

variable "retention_policy" {
  description = "Data retention policy classification"
  type        = string
  default     = "standard"
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "engineering"
}

variable "project_name" {
  description = "Project name for resource organization"
  type        = string
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
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
}

variable "additional_tags" {
  description = "Additional tags to be merged with core tags"
  type        = map(string)
  default     = {}
}

# Outputs
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

output "security_controls_status" {
  description = "Status of implemented security controls"
  value       = module.s3_bucket.security_controls_status
}

output "compliance_status" {
  description = "Overall compliance status"
  value       = module.s3_bucket.compliance_status
}

output "website_configuration" {
  description = "Website hosting configuration"
  value       = module.s3_bucket.website_configuration
}

output "bucket_configuration_summary" {
  description = "Summary of bucket configuration"
  value       = module.s3_bucket.bucket_configuration_summary
}