# Standalone Example - EC2 Module without External Dependencies
# This example can be run without Terraform Cloud or external CCMS modules

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for default VPC (for testing)
data "aws_vpc" "default" {
  default = true
}

# Data source for default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.resource_name}-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_name}-security-group"
  }
}

# EC2 Instance using the module
module "ec2_instance" {
  source = "../../"

  # Required variables
  resource_name = var.resource_name
  environment   = var.environment

  # Instance configuration
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  # Security configuration
  root_block_device_encrypted = true
  metadata_options_http_tokens = "required"
  associate_public_ip_address = false

  # Monitoring
  enable_detailed_monitoring = true
  enable_cloudwatch_alarms   = false  # Disabled due to tag validation issues

  # CCMS compliance tags
  cost_center         = var.cost_center
  project_name        = var.project_name
  owner              = var.owner
  business_unit      = var.business_unit
  application_name   = var.application_name
  data_classification = var.data_classification

  # Additional tags
  additional_tags = {
    Example     = "standalone"
    TestMode    = "true"
    CreatedBy   = "terraform-example"
  }
}