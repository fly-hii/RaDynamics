# Terraform AWS IAM User Module - Variables
# Comprehensive variable definitions for IAM User module

variable "resource_name" {
  description = "Name tag for the IAM User resource"
  type        = string
  validation {
    condition     = length(var.resource_name) > 0 && length(var.resource_name) <= 64
    error_message = "Resource name must be between 1 and 64 characters."
  }
}

variable "username" {
  description = "Name of the IAM user"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.username)) && length(var.username) <= 64
    error_message = "Username must be valid IAM user name (alphanumeric and +=,.@_- characters, max 64 chars)."
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

variable "path" {
  description = "Path for the IAM user"
  type        = string
  default     = "/"
  validation {
    condition     = can(regex("^/.*/$", var.path))
    error_message = "Path must start and end with '/'."
  }
}

variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  type        = string
  default     = null
  validation {
    condition     = var.permissions_boundary_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:policy/.+$", var.permissions_boundary_arn))
    error_message = "Permissions boundary ARN must be a valid IAM policy ARN."
  }
}

variable "force_destroy" {
  description = "When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices"
  type        = bool
  default     = false
}

# Access Configuration
variable "console_access" {
  description = "Whether to create console access (login profile) for the user"
  type        = bool
  default     = false
}

variable "programmatic_access" {
  description = "Whether to create programmatic access (access keys) for the user"
  type        = bool
  default     = false
}

variable "access_key_count" {
  description = "Number of access keys to create (max 2)"
  type        = number
  default     = 1
  validation {
    condition     = var.access_key_count >= 1 && var.access_key_count <= 2
    error_message = "Access key count must be between 1 and 2."
  }
}

# Console Access Configuration
variable "password_reset_required" {
  description = "Whether the user is required to set a new password on next sign-in"
  type        = bool
  default     = true
}

variable "password_length" {
  description = "Length of the generated password"
  type        = number
  default     = 20
  validation {
    condition     = var.password_length >= 4 && var.password_length <= 128
    error_message = "Password length must be between 4 and 128 characters."
  }
}

# Policy Attachments
variable "aws_managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the user"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for arn in var.aws_managed_policy_arns : 
      can(regex("^arn:aws:iam::aws:policy/.+$", arn))
    ])
    error_message = "All AWS managed policy ARNs must be valid."
  }
}

variable "customer_managed_policy_arns" {
  description = "List of customer managed policy ARNs to attach to the user"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for arn in var.customer_managed_policy_arns : 
      can(regex("^arn:aws:iam::[0-9]{12}:policy/.+$", arn))
    ])
    error_message = "All customer managed policy ARNs must be valid."
  }
}

variable "inline_policies" {
  description = "List of inline policies to attach to the user"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for policy in var.inline_policies : 
      length(policy.name) > 0 && length(policy.name) <= 128
    ])
    error_message = "All inline policy names must be between 1 and 128 characters."
  }
}

# Group Memberships
variable "group_memberships" {
  description = "List of IAM groups to add the user to"
  type        = list(string)
  default     = []
}

# MFA Configuration
variable "force_mfa" {
  description = "Whether to enforce MFA for the user"
  type        = bool
  default     = false
}

variable "create_mfa_device" {
  description = "Whether to create a virtual MFA device for the user"
  type        = bool
  default     = false
}

# SSH and Service Credentials
variable "ssh_public_key" {
  description = "SSH public key for CodeCommit access"
  type        = string
  default     = null
}

variable "create_service_credentials" {
  description = "Whether to create service-specific credentials"
  type        = bool
  default     = false
}

variable "service_name" {
  description = "Name of the service for service-specific credentials"
  type        = string
  default     = "codecommit.amazonaws.com"
  validation {
    condition     = contains(["codecommit.amazonaws.com"], var.service_name)
    error_message = "Service name must be a valid AWS service."
  }
}

# CloudTrail Configuration
variable "enable_cloudtrail_logging" {
  description = "Whether to enable CloudTrail logging for the user"
  type        = bool
  default     = false
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = null
}

# Password Policy Configuration
variable "enforce_password_policy" {
  description = "Whether to enforce account-level password policy"
  type        = bool
  default     = false
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length         = number
    require_lowercase      = bool
    require_numbers        = bool
    require_uppercase      = bool
    require_symbols        = bool
    allow_users_to_change  = bool
    hard_expiry           = bool
    max_age_days          = number
    reuse_prevention      = number
  })
  default = {
    minimum_length         = 8
    require_lowercase      = true
    require_numbers        = true
    require_uppercase      = true
    require_symbols        = true
    allow_users_to_change  = true
    hard_expiry           = false
    max_age_days          = 90
    reuse_prevention      = 5
  }
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
  default     = "iam-user-project"
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
  default     = "iam-user-application"
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