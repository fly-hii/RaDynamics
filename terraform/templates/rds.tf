# RDS Instance Terraform Template
# This template creates an RDS database instance with comprehensive configuration
# Includes automatic DB subnet group creation for new AWS accounts

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

# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data source to get subnet details
data "aws_subnet" "default_subnets" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# Create custom DB subnet group if needed
resource "aws_db_subnet_group" "main" {
  count = var.create_subnet_group ? 1 : 0
  
  name       = var.subnet_group_name
  subnet_ids = data.aws_subnets.default.ids
  
  tags = {
    Name        = "IndraSuite DB subnet group"
    CreatedBy   = "IndraSuite"
    ManagedBy   = "Terraform"
    Purpose     = "RDS Database Networking"
  }
  
  # Ensure we have at least 2 subnets in different AZs
  lifecycle {
    precondition {
      condition     = length(data.aws_subnets.default.ids) >= 2
      error_message = "At least 2 subnets are required for RDS DB subnet group."
    }
  }
}

# Local value to determine which subnet group to use
locals {
  # Use the created subnet group if we created it, otherwise use the specified name
  db_subnet_group_name = var.create_subnet_group ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
}

# RDS Instance
resource "aws_db_instance" "main" {
  # Basic Configuration
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = var.storage_type
  storage_encrypted    = var.storage_encrypted
  kms_key_id          = var.kms_key_id
  
  # Database Configuration
  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port
  
  # Network Configuration - Use the determined subnet group
  vpc_security_group_ids = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : null
  db_subnet_group_name   = local.db_subnet_group_name
  publicly_accessible    = var.publicly_accessible
  
  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  copy_tags_to_snapshot  = var.copy_tags_to_snapshot
  
  # Maintenance Configuration
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  # Snapshot Configuration
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  snapshot_identifier       = var.snapshot_identifier
  
  # Security Configuration
  deletion_protection = var.deletion_protection
  
  # Monitoring Configuration
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  
  # Performance Insights
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_kms_key_id      = var.enable_performance_insights ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null
  
  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = var.enable_cloudwatch_logs_exports
  
  # Parameter Group
  parameter_group_name = var.parameter_group_name
  
  # Option Group
  option_group_name = var.option_group_name
  
  # Tags
  tags = merge(
    var.tags,
    {
      Name        = var.identifier
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = var.created_by
    }
  )
  
  # Ensure subnet group is created first if we're creating it
  depends_on = [aws_db_subnet_group.main]
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

# RDS Configuration Variables
variable "identifier" {
  description = "The name of the RDS instance"
  type        = string
}

variable "engine" {
  description = "The database engine"
  type        = string
  validation {
    condition = contains([
      "mysql", "postgres", "mariadb", "oracle-ee", "oracle-se2", 
      "oracle-se1", "oracle-se", "sqlserver-ee", "sqlserver-se", 
      "sqlserver-ex", "sqlserver-web"
    ], var.engine)
    error_message = "Engine must be a valid RDS engine type."
  }
}

variable "engine_version" {
  description = "The engine version"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage"
  type        = number
  default     = null
}

variable "storage_type" {
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)"
  type        = string
  default     = "gp2"
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
  default     = null
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = null
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "create_subnet_group" {
  description = "Whether to create a custom DB subnet group"
  type        = bool
  default     = true
}

variable "subnet_group_name" {
  description = "Name for the DB subnet group to create"
  type        = string
  default     = "indrasuite-db-subnet-group"
}

variable "db_subnet_group_name" {
  description = "Name of existing DB subnet group to use (if not creating new one)"
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 0
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "copy_tags_to_snapshot" {
  description = "On delete, copy all Instance tags to the final snapshot"
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted"
  type        = string
  default     = null
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval for collecting enhanced monitoring metrics"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role for enhanced monitoring"
  type        = string
  default     = null
}

variable "enable_performance_insights" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "enable_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate"
  type        = string
  default     = null
}

variable "option_group_name" {
  description = "Name of the DB option group to associate"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Outputs
output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_port" {
  description = "The RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.main.status
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password"
  value       = aws_db_instance.main.password
  sensitive   = true
}

output "db_instance_engine" {
  description = "The database engine"
  value       = aws_db_instance.main.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database"
  value       = aws_db_instance.main.engine_version
}

output "db_instance_class" {
  description = "The RDS instance class"
  value       = aws_db_instance.main.instance_class
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.main.availability_zone
}

output "db_instance_backup_retention_period" {
  description = "The backup retention period"
  value       = aws_db_instance.main.backup_retention_period
}

output "db_instance_backup_window" {
  description = "The backup window"
  value       = aws_db_instance.main.backup_window
}

output "db_instance_maintenance_window" {
  description = "The instance maintenance window"
  value       = aws_db_instance.main.maintenance_window
}

output "db_instance_multi_az" {
  description = "If the RDS instance is multi AZ enabled"
  value       = aws_db_instance.main.multi_az
}

output "db_instance_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  value       = aws_db_instance.main.storage_encrypted
}