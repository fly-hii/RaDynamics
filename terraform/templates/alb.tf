# Application Load Balancer Terraform Template
# This template creates an ALB with target groups and listeners

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

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.load_balancer_name
  internal           = var.scheme == "internal"
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = var.enable_http2
  ip_address_type           = var.ip_address_type
  idle_timeout              = var.idle_timeout

  tags = merge(
    var.tags,
    {
      Name        = var.load_balancer_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Default Target Group
resource "aws_lb_target_group" "default" {
  name     = "${var.load_balancer_name}-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.load_balancer_name}-default-tg"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# Default HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.load_balancer_name}-http-listener"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
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

variable "load_balancer_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs to attach to the LB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to assign to the LB"
  type        = list(string)
  default     = []
}

variable "scheme" {
  description = "If true, the LB will be internal"
  type        = string
  default     = "internet-facing"
  validation {
    condition     = contains(["internet-facing", "internal"], var.scheme)
    error_message = "Scheme must be either 'internet-facing' or 'internal'."
  }
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer"
  type        = string
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "IP address type must be either 'ipv4' or 'dualstack'."
  }
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "target_groups" {
  description = "List of target group configurations"
  type        = list(any)
  default     = []
}

variable "listeners" {
  description = "List of listener configurations"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "load_balancer_id" {
  description = "The ID and ARN of the load balancer"
  value       = aws_lb.main.id
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the default target group"
  value       = aws_lb_target_group.default.arn
}

output "target_group_name" {
  description = "Name of the default target group"
  value       = aws_lb_target_group.default.name
}

output "listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}