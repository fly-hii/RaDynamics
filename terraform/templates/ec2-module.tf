# AWS Provider Configuration
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
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Module    = "ec2-comprehensive"
    }
  }
}

# Comprehensive EC2 Instance using the enterprise module
module "ec2_instance" {
  source = "./modules/ec2-module"

  # Required variables
  resource_name = var.resource_name
  environment   = var.environment

  # Instance configuration
  instance_type = var.instance_type
  ami_id        = var.ami_id
  key_name      = var.key_name

  # Network configuration
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = var.availability_zone

  # Storage configuration
  root_block_device_volume_size = var.root_block_device_volume_size
  root_block_device_volume_type = var.root_block_device_volume_type
  root_block_device_encrypted   = var.root_block_device_encrypted
  root_block_device_delete_on_termination = var.root_block_device_delete_on_termination

  # User data configuration
  user_data_base64    = var.user_data_base64
  user_data_template  = var.user_data_template
  user_data_variables = var.user_data_variables

  # Security configuration
  metadata_options_http_tokens = var.metadata_options_http_tokens
  require_encryption          = var.require_encryption
  enforce_imdsv2             = var.enforce_imdsv2
  security_controls_enabled  = var.security_controls_enabled

  # Monitoring configuration
  enable_detailed_monitoring = var.enable_detailed_monitoring
  enable_cloudwatch_alarms   = var.enable_cloudwatch_alarms
  cpu_utilization_threshold  = var.cpu_utilization_threshold

  # IAM configuration
  iam_instance_profile_name = var.iam_instance_profile_name

  # CCMS compliance tags
  cost_center         = var.cost_center
  project_name        = var.project_name
  owner              = var.owner
  business_unit      = var.business_unit
  application_name   = var.application_name
  data_classification = var.data_classification

  # Additional tags
  additional_tags = var.additional_tags
  
  # Security configuration
  disable_api_termination = var.disable_api_termination
  security_compliance_tags = var.security_compliance_tags
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
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

variable "resource_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = null
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Associate public IP"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = null
}

variable "root_block_device_volume_size" {
  description = "Root volume size"
  type        = number
  default     = 20
}

variable "root_block_device_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_block_device_encrypted" {
  description = "Encrypt root volume"
  type        = bool
  default     = true
}

variable "root_block_device_delete_on_termination" {
  description = "Delete root volume on termination"
  type        = bool
  default     = true
}

variable "user_data_base64" {
  description = "User data (base64 encoded)"
  type        = string
  default     = null
}

variable "user_data_template" {
  description = "User data template name"
  type        = string
  default     = null
}

variable "user_data_variables" {
  description = "User data template variables"
  type        = map(string)
  default     = {}
}

variable "metadata_options_http_tokens" {
  description = "Metadata HTTP tokens"
  type        = string
  default     = "required"
}

variable "require_encryption" {
  description = "Require encryption"
  type        = bool
  default     = true
}

variable "enforce_imdsv2" {
  description = "Enforce IMDSv2"
  type        = bool
  default     = true
}

variable "security_controls_enabled" {
  description = "Enable security controls"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = false
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold"
  type        = number
  default     = 80
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Cost center"
  type        = string
  default     = "engineering"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "owner" {
  description = "Owner"
  type        = string
  default     = "terraform-user"
}

variable "business_unit" {
  description = "Business unit"
  type        = string
  default     = "engineering"
}

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "data_classification" {
  description = "Data classification"
  type        = string
  default     = "internal"
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "disable_api_termination" {
  description = "Enable EC2 Instance Termination Protection"
  type        = bool
  default     = false
}

variable "security_compliance_tags" {
  description = "Security compliance tags"
  type        = map(string)
  default     = {}
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = module.ec2_instance.instance_arn
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = module.ec2_instance.instance_state
}

output "private_ip" {
  description = "Private IP address"
  value       = module.ec2_instance.private_ip
}

output "public_ip" {
  description = "Public IP address"
  value       = module.ec2_instance.public_ip
}

output "security_controls_status" {
  description = "Security controls status"
  value       = module.ec2_instance.security_controls_status
}

output "encryption_status" {
  description = "Encryption status"
  value       = module.ec2_instance.encryption_status
}