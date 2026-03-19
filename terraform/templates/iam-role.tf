# IAM Role Terraform Template
# This template creates an IAM role with policies

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# IAM Role
resource "aws_iam_role" "main" {
  name                 = var.role_name
  assume_role_policy   = var.assume_role_policy
  description          = var.description
  max_session_duration = var.max_session_duration
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  tags = merge(
    var.tags,
    {
      Name        = var.role_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Attach managed policies
resource "aws_iam_role_policy_attachment" "managed" {
  count = length(var.policies)

  role       = aws_iam_role.main.name
  policy_arn = var.policies[count.index]
}

# Inline policies
resource "aws_iam_role_policy" "inline" {
  count = length(var.inline_policies)

  name   = var.inline_policies[count.index].name
  role   = aws_iam_role.main.id
  policy = var.inline_policies[count.index].policy
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

variable "deployment_id" {
  description = "Deployment ID"
  type        = string
  default     = ""
}

variable "created_by" {
  description = "Created by user"
  type        = string
  default     = "terraform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "role_name" {
  description = "Friendly name of the role"
  type        = string
}

variable "assume_role_policy" {
  description = "Policy that grants an entity permission to assume the role"
  type        = string
}

variable "description" {
  description = "Description of the role"
  type        = string
  default     = "IAM role created by IndraSuite"
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role"
  type        = number
  default     = 3600
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds (1 to 12 hours)."
  }
}

variable "path" {
  description = "Path to the role"
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "policies" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "List of inline policy documents to attach to IAM role"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = aws_iam_role.main.arn
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = aws_iam_role.main.name
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = aws_iam_role.main.path
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = aws_iam_role.main.unique_id
}

output "iam_role_create_date" {
  description = "Creation date of the IAM role"
  value       = aws_iam_role.main.create_date
}