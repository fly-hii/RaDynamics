# Basic Example for AWS EC2 Module
# Demonstrates minimal configuration for creating an EC2 instance

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  default_tags {
    tags = {
      Example     = "terraform-aws-l1-ec2-basic"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Basic EC2 instance using the L1 module
module "basic_ec2_instance" {
  source = "../../"

  # Required variables
  resource_name = var.instance_name
  environment   = var.environment

  # Basic configuration
  instance_type = var.instance_type
  key_name      = var.key_name

  # Network configuration
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip

  # Storage configuration (using defaults with encryption)
  root_block_device_volume_size = var.root_volume_size
  root_block_device_encrypted   = true

  # Basic monitoring
  enable_detailed_monitoring = var.enable_monitoring

  # Additional tags
  additional_tags = {
    Purpose     = "basic-example"
    Application = "demo"
    Owner       = "platform-team"
  }
}