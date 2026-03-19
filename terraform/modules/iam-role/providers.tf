# Terraform AWS IAM Role Module - Provider Configuration
# Provider requirements and configuration for IAM Role module

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# AWS Provider configuration is inherited from the root module
# No explicit provider configuration needed here