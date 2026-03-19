# Security Group Terraform Template
# This template creates a security group with ingress and egress rules

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

# Security Group
resource "aws_security_group" "main" {
  name        = var.group_name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = var.group_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Ingress Rules
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = "ingress"
  security_group_id = aws_security_group.main.id

  from_port   = var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].to_port
  protocol    = var.ingress_rules[count.index].protocol
  cidr_blocks = lookup(var.ingress_rules[count.index], "cidr_blocks", null)
  
  source_security_group_id = lookup(var.ingress_rules[count.index], "source_security_group_id", null)
  self                     = lookup(var.ingress_rules[count.index], "self", null)
  
  description = lookup(var.ingress_rules[count.index], "description", "Ingress rule")
}

# Egress Rules
resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type              = "egress"
  security_group_id = aws_security_group.main.id

  from_port   = var.egress_rules[count.index].from_port
  to_port     = var.egress_rules[count.index].to_port
  protocol    = var.egress_rules[count.index].protocol
  cidr_blocks = lookup(var.egress_rules[count.index], "cidr_blocks", null)
  
  source_security_group_id = lookup(var.egress_rules[count.index], "source_security_group_id", null)
  self                     = lookup(var.egress_rules[count.index], "self", null)
  
  description = lookup(var.egress_rules[count.index], "description", "Egress rule")
}

# Default egress rule (allow all outbound traffic) if no egress rules specified
resource "aws_security_group_rule" "default_egress" {
  count = length(var.egress_rules) == 0 ? 1 : 0

  type              = "egress"
  security_group_id = aws_security_group.main.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  
  description = "Default egress rule - allow all outbound traffic"
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

variable "group_name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules to create by name"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks             = optional(list(string))
    source_security_group_id = optional(string)
    self                    = optional(bool)
    description             = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules to create by name"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks             = optional(list(string))
    source_security_group_id = optional(string)
    self                    = optional(bool)
    description             = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.main.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.main.name
}

output "security_group_description" {
  description = "Description of the security group"
  value       = aws_security_group.main.description
}

output "security_group_vpc_id" {
  description = "ID of the VPC"
  value       = aws_security_group.main.vpc_id
}

output "security_group_owner_id" {
  description = "Owner ID"
  value       = aws_security_group.main.owner_id
}