# Terraform AWS IAM Policy Module - Variables
# Comprehensive variable definitions for IAM Policy module

variable "resource_name" {
  description = "Name tag for the IAM Policy resource"
  type        = string
  validation {
    condition     = length(var.resource_name) > 0 && length(var.resource_name) <= 64
    error_message = "Resource name must be between 1 and 64 characters."
  }
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = null
  validation {
    condition     = var.policy_name == null || (can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.policy_name)) && length(var.policy_name) <= 128)
    error_message = "Policy name must be valid IAM policy name (alphanumeric and +=,.@_- characters, max 128 chars)."
  }
}

variable "policy_name_prefix" {
  description = "Name prefix for the IAM policy (creates unique names)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, test, staging, prod."
  }
}

variable "path" {
  description = "Path for the IAM policy"
  type        = string
  default     = "/"
  validation {
    condition     = can(regex("^/.*/$", var.path))
    error_message = "Path must start and end with '/'."
  }
}

variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "IAM policy managed by Terraform"
  validation {
    condition     = length(var.description) <= 1000
    error_message = "Description must be 1000 characters or less."
  }
}

variable "policy_document" {
  description = "JSON policy document"
  type        = string
  validation {
    condition     = can(jsondecode(var.policy_document))
    error_message = "Policy document must be valid JSON."
  }
  validation {
    condition     = length(var.policy_document) <= 6144
    error_message = "Policy document must be 6144 characters or less."
  }
}

variable "policy_type" {
  description = "Type of policy (managed, inline, aws-managed)"
  type        = string
  default     = "managed"
  validation {
    condition     = contains(["managed", "inline", "aws-managed"], var.policy_type)
    error_message = "Policy type must be one of: managed, inline, aws-managed."
  }
}

# Policy Version Management
variable "create_policy_version" {
  description = "Whether to create a new policy version"
  type        = bool
  default     = false
}

# Attachment Configuration
variable "attach_to_users" {
  description = "List of IAM user names to attach the policy to"
  type        = list(string)
  default     = []
}

variable "attach_to_roles" {
  description = "List of IAM role names to attach the policy to"
  type        = list(string)
  default     = []
}

variable "attach_to_groups" {
  description = "List of IAM group names to attach the policy to"
  type        = list(string)
  default     = []
}

# Policy Testing and Analysis
variable "run_policy_simulator" {
  description = "Whether to run policy simulator tests"
  type        = bool
  default     = false
}

variable "enable_policy_analysis" {
  description = "Whether to enable policy analysis and validation"
  type        = bool
  default     = true
}

# CloudTrail Configuration
variable "enable_cloudtrail_logging" {
  description = "Whether to enable CloudTrail logging for the policy"
  type        = bool
  default     = false
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = null
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
  default     = "iam-policy-project"
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
  default     = "iam-policy-application"
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