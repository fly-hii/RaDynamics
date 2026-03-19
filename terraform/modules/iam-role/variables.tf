# Terraform AWS IAM Role Module - Variables
# Comprehensive variable definitions for IAM Role module

variable "resource_name" {
  description = "Name tag for the IAM Role resource"
  type        = string
  validation {
    condition     = length(var.resource_name) > 0 && length(var.resource_name) <= 64
    error_message = "Resource name must be between 1 and 64 characters."
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

variable "role_name_prefix" {
  description = "Name prefix for the IAM role (creates unique names)"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role managed by Terraform"
  validation {
    condition     = length(var.description) <= 1000
    error_message = "Description must be 1000 characters or less."
  }
}

variable "path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
  validation {
    condition     = can(regex("^/.*/$", var.path))
    error_message = "Path must start and end with '/'."
  }
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds."
  }
}

# Trust Relationship Configuration
variable "trusted_role_services" {
  description = "List of AWS services that can assume this role"
  type        = list(string)
  default     = null
  
  validation {
    condition = var.trusted_role_services == null || alltrue([
      for service in var.trusted_role_services : 
      can(regex("^[a-z0-9.-]+\\.amazonaws\\.com$", service))
    ])
    error_message = "All services must be valid AWS service principals (e.g., ec2.amazonaws.com)."
  }
}

variable "trusted_role_arns" {
  description = "List of AWS account IDs or role ARNs that can assume this role"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for arn in var.trusted_role_arns : 
      can(regex("^arn:aws:iam::[0-9]{12}:(root|role/.+)$", arn)) || can(regex("^[0-9]{12}$", arn))
    ])
    error_message = "All ARNs must be valid AWS account IDs or IAM role ARNs."
  }
}

variable "external_id" {
  description = "External ID for cross-account role assumption"
  type        = string
  default     = null
  validation {
    condition     = var.external_id == null || length(var.external_id) >= 2 && length(var.external_id) <= 1224
    error_message = "External ID must be between 2 and 1224 characters if specified."
  }
}

# Security Configuration
variable "require_mfa" {
  description = "Whether to require MFA for role assumption"
  type        = bool
  default     = false
}

variable "require_external_id" {
  description = "Whether to require external ID for role assumption"
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to assume this role"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_ip_ranges : 
      can(cidrhost(cidr, 0))
    ])
    error_message = "All IP ranges must be valid CIDR blocks."
  }
}

variable "time_based_access" {
  description = "Time-based access restrictions"
  type = object({
    start_time = string
    end_time   = string
  })
  default = null
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

variable "force_detach_policies" {
  description = "Whether to force detach policies when destroying the role"
  type        = bool
  default     = false
}

# Policy Attachments
variable "aws_managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
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
  description = "List of customer managed policy ARNs to attach to the role"
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
  description = "List of inline policies to attach to the role"
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

# Instance Profile Configuration
variable "create_instance_profile" {
  description = "Whether to create an instance profile for EC2 instances"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile"
  type        = string
  default     = null
}

variable "instance_profile_name_prefix" {
  description = "Name prefix for the instance profile"
  type        = string
  default     = null
}

# CloudTrail Configuration
variable "enable_cloudtrail_logging" {
  description = "Whether to enable CloudTrail logging for the role"
  type        = bool
  default     = false
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for CloudTrail"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "cloudwatch_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = null
}

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
  default     = "iam-role-project"
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
  default     = "iam-role-application"
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