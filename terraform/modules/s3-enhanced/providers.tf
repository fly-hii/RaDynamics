# Terraform AWS S3 Enhanced Module - Provider Configuration
# Provider requirements and configuration for S3 enhanced module

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

# AWS Provider Features Used (L2 Enhanced):
# All L1 features plus:
# - S3 bucket replication configuration
# - S3 bucket analytics configuration
# - S3 bucket inventory configuration
# - S3 bucket intelligent tiering configuration
# - AWS Backup vault, plan, and selection
# - IAM roles and policies for replication and backup
# - CloudWatch dashboards
# - Enhanced CloudWatch metric alarms
# - AWS region data source

# Provider Tags Configuration (Optional)
# The enhanced module supports provider-level default tags through the AWS provider
# Example provider configuration at root module level:
#
# provider "aws" {
#   region = var.aws_region
#   
#   default_tags {
#     tags = {
#       ManagedBy   = "terraform"
#       Module      = "s3-enhanced"
#       Tier        = "L2"
#       Environment = var.environment
#     }
#   }
# }

# Multi-Region Support
# For cross-region replication, you may need to configure multiple AWS providers:
#
# provider "aws" {
#   alias  = "replica"
#   region = var.replica_region
#   
#   default_tags {
#     tags = {
#       ManagedBy = "terraform"
#       Module    = "s3-enhanced"
#       Purpose   = "replication"
#     }
#   }
# }

# Required AWS Permissions (L2 Enhanced):
# All L1 permissions plus:
#
# S3 Enhanced Permissions:
# - s3:PutReplicationConfiguration
# - s3:GetReplicationConfiguration
# - s3:DeleteReplicationConfiguration
# - s3:PutAnalyticsConfiguration
# - s3:GetAnalyticsConfiguration
# - s3:DeleteAnalyticsConfiguration
# - s3:PutInventoryConfiguration
# - s3:GetInventoryConfiguration
# - s3:DeleteInventoryConfiguration
# - s3:PutIntelligentTieringConfiguration
# - s3:GetIntelligentTieringConfiguration
# - s3:DeleteIntelligentTieringConfiguration
#
# AWS Backup Permissions:
# - backup:CreateBackupVault
# - backup:DeleteBackupVault
# - backup:DescribeBackupVault
# - backup:CreateBackupPlan
# - backup:DeleteBackupPlan
# - backup:DescribeBackupPlan
# - backup:CreateBackupSelection
# - backup:DeleteBackupSelection
# - backup:DescribeBackupJob
# - backup:StartBackupJob
#
# Enhanced IAM Permissions:
# - iam:CreateRole
# - iam:DeleteRole
# - iam:AttachRolePolicy
# - iam:DetachRolePolicy
# - iam:CreatePolicy
# - iam:DeletePolicy
# - iam:PassRole
#
# Enhanced CloudWatch Permissions:
# - cloudwatch:PutDashboard
# - cloudwatch:DeleteDashboards
# - cloudwatch:GetDashboard
# - cloudwatch:ListDashboards
# - cloudwatch:PutMetricAlarm
# - cloudwatch:DeleteAlarms
# - cloudwatch:DescribeAlarms
#
# KMS Permissions (Enhanced):
# - kms:CreateKey
# - kms:DescribeKey
# - kms:GetKeyPolicy
# - kms:PutKeyPolicy
# - kms:CreateAlias
# - kms:DeleteAlias
# - kms:Encrypt
# - kms:Decrypt
# - kms:ReEncrypt*
# - kms:GenerateDataKey*
# - kms:DescribeKey