# Auto Scaling Group Terraform Template
# This template creates an Auto Scaling Group with comprehensive configuration

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

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = var.name
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = var.target_group_arns
  load_balancers      = var.load_balancers

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  enabled_metrics           = var.enabled_metrics
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  max_instance_lifetime     = var.max_instance_lifetime

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = launch_template.value.id
      version = launch_template.value.version
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # Default tags
  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "CreatedBy"
    value               = var.created_by
    propagate_at_launch = true
  }
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

variable "name" {
  description = "The name of the Auto Scaling Group"
  type        = string
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
  default     = null
}

variable "launch_template" {
  description = "Configuration block with launch template specification"
  type = object({
    id      = string
    version = string
  })
  default = null
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}

variable "target_group_arns" {
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = []
}

variable "load_balancers" {
  description = "A list of elastic load balancer names to add to the autoscaling group names"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity may start"
  type        = number
  default     = 300
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate"
  type        = bool
  default     = false
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated"
  type        = list(string)
  default     = ["Default"]
}

variable "suspended_processes" {
  description = "A list of processes to suspend for the AutoScaling Group"
  type        = list(string)
  default     = []
}

variable "placement_group" {
  description = "The name of the placement group into which you'll launch your instances"
  type        = string
  default     = null
}

variable "enabled_metrics" {
  description = "A list of metrics to collect"
  type        = list(string)
  default     = []
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  type        = string
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection"
  type        = bool
  default     = false
}

variable "service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  type        = string
  default     = null
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service"
  type        = number
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = aws_autoscaling_group.main.min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = aws_autoscaling_group.main.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = aws_autoscaling_group.main.desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = aws_autoscaling_group.main.default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = aws_autoscaling_group.main.health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = aws_autoscaling_group.main.health_check_type
}