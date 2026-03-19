# ECS Cluster and Service Terraform Template
# This template creates an ECS cluster with service and task definition

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

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_logging ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name        = var.cluster_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  count = var.enable_logging ? 1 : 0
  
  name              = var.log_group_name
  retention_in_days = 14

  tags = merge(
    var.tags,
    {
      Name        = var.log_group_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.task_definition_family
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  container_definitions = jsonencode(var.container_definitions)

  tags = merge(
    var.tags,
    {
      Name        = var.task_definition_family
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []
    content {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = var.assign_public_ip
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.service_name
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

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_definition_family" {
  description = "A unique name for your task definition"
  type        = string
}

variable "container_definitions" {
  description = "A list of valid container definitions"
  type        = list(any)
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type on which to run your service"
  type        = string
  default     = "FARGATE"
}

variable "network_mode" {
  description = "Docker networking mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "Number of cpu units used by the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task"
  type        = string
  default     = "512"
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets associated with the task or service"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups associated with the task or service"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = "/ecs/default"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "service_id" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "Full ARN of the Task Definition"
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "The family of the Task Definition"
  value       = aws_ecs_task_definition.main.family
}

output "task_definition_revision" {
  description = "The revision of the task in a particular family"
  value       = aws_ecs_task_definition.main.revision
}