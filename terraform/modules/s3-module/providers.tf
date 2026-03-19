# Terraform AWS S3 Module - Provider Configuration
# Provider requirements and configuration for S3 module

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# AWS Provider configuration
# Note: Provider configuration is typically handled at the root module level
# This file documents the required provider versions and features used

# AWS Provider Features Used:
# - S3 bucket management and configuration
# - S3 bucket versioning
# - S3 server-side encryption
# - S3 public access block
# - S3 bucket policy
# - S3 access logging
# - S3 lifecycle configuration
# - S3 CORS configuration
# - S3 website configuration
# - S3 transfer acceleration
# - S3 request payment configuration
# - S3 object lock configuration
# - S3 notification configuration
# - S3 intelligent tiering
# - CloudWatch log metric filters
# - CloudWatch metric alarms
# - KMS key data source
# - AWS caller identity data source

# Provider Tags Configuration (Optional)
# The module supports provider-level default tags through the AWS provider
# Example provider configuration at root module level:
#
# provider "aws" {
#   region = var.aws_region
#   
#   default_tags {
#     tags = {
#       ManagedBy   = "terraform"
#       Module      = "s3-module"
#       Environment = var.environment
#     }
#   }
# }

# Required AWS Permissions:
# The following IAM permissions are required for this module:
#
# S3 Permissions:
# - s3:CreateBucket
# - s3:DeleteBucket
# - s3:GetBucketVersioning
# - s3:PutBucketVersioning
# - s3:GetEncryptionConfiguration
# - s3:PutEncryptionConfiguration
# - s3:GetBucketPublicAccessBlock
# - s3:PutBucketPublicAccessBlock
# - s3:GetBucketPolicy
# - s3:PutBucketPolicy
# - s3:DeleteBucketPolicy
# - s3:GetBucketLogging
# - s3:PutBucketLogging
# - s3:GetLifecycleConfiguration
# - s3:PutLifecycleConfiguration
# - s3:GetBucketCors
# - s3:PutBucketCors
# - s3:GetBucketWebsite
# - s3:PutBucketWebsite
# - s3:GetAccelerateConfiguration
# - s3:PutAccelerateConfiguration
# - s3:GetBucketRequestPayment
# - s3:PutBucketRequestPayment
# - s3:GetObjectLockConfiguration
# - s3:PutObjectLockConfiguration
# - s3:GetBucketNotification
# - s3:PutBucketNotification
# - s3:GetIntelligentTieringConfiguration
# - s3:PutIntelligentTieringConfiguration
# - s3:GetBucketTagging
# - s3:PutBucketTagging
#
# CloudWatch Permissions:
# - logs:CreateLogGroup
# - logs:PutMetricFilter
# - logs:DeleteMetricFilter
# - cloudwatch:PutMetricAlarm
# - cloudwatch:DeleteAlarms
#
# KMS Permissions (if using KMS encryption):
# - kms:DescribeKey
# - kms:GetKeyPolicy
# - kms:ListAliases
#
# IAM Permissions:
# - sts:GetCallerIdentity