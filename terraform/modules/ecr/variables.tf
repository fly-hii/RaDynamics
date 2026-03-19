# Terraform AWS ECR Module - Variables
# Comprehensive variable definitions for ECR module with security controls

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._-][a-z0-9]+)*$", var.repository_name))
    error_message = "Repository name must be lowercase alphanumeric with optional separators (., -, _)."
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

variable "image_tag_mutability" {
  description = "Image tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images"
  type        = bool
  default     = false
}

# Image Scanning Configuration
variable "image_scanning_configuration" {
  description = "Configuration for image scanning"
  type = object({
    scan_on_push = bool
  })
  default = {
    scan_on_push = true
  }
}

# Encryption Configuration
variable "encryption_configuration" {
  description = "Encryption configuration for the repository"
  type = object({
    encryption_type = string
    kms_key        = string
  })
  default = null
  validation {
    condition = var.encryption_configuration == null || contains(["AES256", "KMS"], var.encryption_configuration.encryption_type)
    error_message = "Encryption type must be either 'AES256' or 'KMS'."
  }
}

# Repository Policy
variable "repository_policy" {
  description = "JSON policy document for the repository"
  type        = string
  default     = null
}

# Lifecycle Policy
variable "lifecycle_policy" {
  description = "JSON lifecycle policy document for the repository"
  type        = string
  default     = null
}

# Registry Scanning Configuration
variable "enable_registry_scanning" {
  description = "Whether to enable registry scanning configuration"
  type        = bool
  default     = false
}

variable "registry_scan_type" {
  description = "Scanning type for the registry"
  type        = string
  default     = "ENHANCED"
  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.registry_scan_type)
    error_message = "Registry scan type must be either 'BASIC' or 'ENHANCED'."
  }
}

variable "registry_scan_rules" {
  description = "Registry scanning rules"
  type = list(object({
    scan_frequency = string
    repository_filter = object({
      filter      = string
      filter_type = string
    })
  }))
  default = []
}

# Replication Configuration
variable "replication_configuration" {
  description = "Replication configuration for the registry"
  type = list(object({
    destinations = list(object({
      region      = string
      registry_id = string
    }))
    repository_filters = list(object({
      filter      = string
      filter_type = string
    }))
  }))
  default = []
}

# Registry Policy
variable "registry_policy" {
  description = "JSON policy document for the registry"
  type        = string
  default     = null
}

# CloudWatch Configuration
variable "create_cloudwatch_log_group" {
  description = "Whether to create a CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events"
  type        = number
  default     = 30
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_in_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention period."
  }
}

variable "log_group_kms_key_id" {
  description = "KMS key ID for log group encryption"
  type        = string
  default     = null
}

variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = true
}

variable "repository_size_threshold" {
  description = "Repository size threshold in bytes for CloudWatch alarm"
  type        = number
  default     = 10737418240 # 10 GB
}

variable "image_count_threshold" {
  description = "Image count threshold for CloudWatch alarm"
  type        = number
  default     = 100
}

variable "alarm_actions" {
  description = "List of alarm actions"
  type        = list(string)
  default     = []
}

# Security Configuration
variable "security_controls_enabled" {
  description = "Whether to enable security controls validation"
  type        = bool
  default     = true
}

variable "security_compliance_tags" {
  description = "Security compliance tags"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to be merged with core tags"
  type        = map(string)
  default     = {}
}

# CCMS compliance variables
variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "default-cost-center"
}

variable "project_name" {
  description = "Project name for resource organization"
  type        = string
  default     = "ecr-project"
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
  default     = "ecr-application"
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