# Basic S3 Enhanced Module Example
# This example demonstrates the minimal configuration required for the S3 Enhanced module

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
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Random suffix for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Basic S3 Enhanced Module Usage
module "s3_basic_example" {
  source = "../../"
  
  # Required variables
  bucket_name = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  environment = var.environment
  
  # CCMS Compliance variables
  cost_center         = var.cost_center
  project_name        = var.project_name
  owner              = var.owner
  business_unit      = var.business_unit
  application_name   = var.application_name
  data_classification = var.data_classification
  
  # Basic security configuration
  encryption_type     = "AES256"
  enable_versioning   = true
  block_public_access = true
  enable_ssl_only     = true
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Purpose     = "demonstration"
    Terraform   = "true"
    Environment = var.environment
  }
}