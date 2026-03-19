# Terraform AWS CloudFront Module - Provider Configuration
# Provider requirements and configuration for CloudFront module

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# AWS Provider configuration
# Note: Provider configuration is typically done at the root module level
# This is here for reference and module testing purposes

# provider "aws" {
#   region = var.aws_region
#   
#   default_tags {
#     tags = {
#       ManagedBy = "terraform"
#       Module    = "terraform-aws-cloudfront"
#     }
#   }
# }

# CloudFront distributions are global resources but require us-east-1 for certain operations
# This provider alias can be used for ACM certificates and Lambda@Edge functions
# provider "aws" {
#   alias  = "us_east_1"
#   region = "us-east-1"
#   
#   default_tags {
#     tags = {
#       ManagedBy = "terraform"
#       Module    = "terraform-aws-cloudfront"
#     }
#   }
# }