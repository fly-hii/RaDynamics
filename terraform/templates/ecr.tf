# ECR Repository Terraform Template
# This template creates an ECR repository with comprehensive configuration

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

# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  dynamic "image_scanning_configuration" {
    for_each = var.image_scanning_configuration != null ? [var.image_scanning_configuration] : []
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration != null ? [var.encryption_configuration] : []
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key        = lookup(encryption_configuration.value, "kms_key", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.repository_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "main" {
  count = var.lifecycle_policy != null ? 1 : 0
  
  repository = aws_ecr_repository.main.name
  policy     = var.lifecycle_policy
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "main" {
  count = var.repository_policy != null ? 1 : 0
  
  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy
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

variable "repository_name" {
  description = "Name of the repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "image_scanning_configuration" {
  description = "Configuration block that defines image scanning configuration"
  type = object({
    scan_on_push = bool
  })
  default = {
    scan_on_push = false
  }
}

variable "encryption_configuration" {
  description = "Encryption configuration for the repository"
  type = object({
    encryption_type = string
    kms_key        = optional(string)
  })
  default = null
}

variable "lifecycle_policy" {
  description = "The policy document for the lifecycle policy"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "The JSON policy to apply to the repository"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "repository_arn" {
  description = "Full ARN of the repository"
  value       = aws_ecr_repository.main.arn
}

output "repository_name" {
  description = "Name of the repository"
  value       = aws_ecr_repository.main.name
}

output "repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.main.repository_url
}

output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = aws_ecr_repository.main.registry_id
}