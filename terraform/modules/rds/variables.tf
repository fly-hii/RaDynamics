# Terraform AWS RDS Module - Variables
# Comprehensive variable definitions for RDS module

variable "resource_name" {
  description = "Name tag for the RDS instance resource"
  type        = string
  validation {
    condition     = length(var.resource_name) > 0 && length(var.resource_name) <= 63
    error_message = "Resource name must be between 1 and 63 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, test, staging, prod."
  }
}

variable "identifier" {
  description = "The name of the RDS instance"
  type        = string
  default     = null
}

# Engine Configuration
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
  description = "The engine version to use"
  type        = string
}

variable "major_engine_version" {
  description = "Major engine version for option group"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  validation {
    condition = can(regex("^db\\.[a-z0-9]+\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge)$", var.instance_class))
    error_message = "Instance class must be a valid RDS instance type."
  }
}

# Storage Configuration
variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage"
  type        = number
  default     = null
}

variable "storage_type" {
  description = "One of standard (magnetic), gp2 (general purpose SSD), gp3, or io1 (provisioned IOPS SSD)"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "Storage type must be one of: standard, gp2, gp3, io1, io2."
  }
}

variable "storage_throughput" {
  description = "Storage throughput value for gp3 storage type"
  type        = number
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS"
  type        = number
  default     = null
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

# Database Configuration
variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = null
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
  validation {
    condition     = length(var.username) >= 1 && length(var.username) <= 63
    error_message = "Username must be between 1 and 63 characters."
  }
}

variable "password" {
  description = "Password for the master DB user"
  type        = string
  default     = null
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = false
}

variable "master_user_secret_kms_key_id" {
  description = "The Amazon Web Services KMS key identifier for encryption of the master user password"
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

# Network Configuration
variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be valid (vpc-xxxxxxxx format)."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
  default     = null
  validation {
    condition = var.subnet_ids == null || alltrue([
      for subnet in var.subnet_ids : can(regex("^subnet-[a-f0-9]{8,17}$", subnet))
    ])
    error_message = "All subnet IDs must be valid (subnet-xxxxxxxx format)."
  }
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for sg in var.vpc_security_group_ids : can(regex("^sg-[a-f0-9]{8,17}$", sg))
    ])
    error_message = "All security group IDs must be valid (sg-xxxxxxxx format)."
  }
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The AZ for the RDS instance"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

# Parameter and Option Groups
variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "The DB parameter group family"
  type        = string
  default     = "mysql8.0"
}

variable "parameters" {
  description = "A list of DB parameters to apply"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "option_group_name" {
  description = "Name of the DB option group to associate"
  type        = string
  default     = null
}

variable "options" {
  description = "A list of Options to apply"
  type = list(object({
    option_name = string
    option_settings = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default = []
}

# Backup Configuration
variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "monitoring_interval" {
  description = "The interval for collecting enhanced monitoring metrics"
  type        = number
  default     = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role for enhanced monitoring"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
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
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

# Version Management
variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately"
  type        = bool
  default     = false
}

# Read Replica Configuration
variable "create_read_replica" {
  description = "Whether to create a read replica"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "The instance class for the read replica"
  type        = string
  default     = null
}

# CloudWatch Alarms
variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = false
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "connection_count_threshold" {
  description = "Connection count threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "freeable_memory_threshold" {
  description = "Freeable memory threshold for CloudWatch alarm (in bytes)"
  type        = number
  default     = 268435456  # 256 MB
}

variable "alarm_actions" {
  description = "List of alarm actions"
  type        = list(string)
  default     = []
}

variable "security_controls_enabled" {
  description = "Whether to enable security controls validation"
  type        = bool
  default     = true
}

variable "security_compliance_tags" {
  description = "Security compliance tags"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to be merged with core tags"
  type        = map(string)
  default     = {}
}

# CCMS compliance variables
variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "default-cost-center"
}

variable "project_name" {
  description = "Project name for resource organization"
  type        = string
  default     = "rds-project"
}

variable "owner" {
  description = "Resource owner for accountability"
  type        = string
  default     = "terraform-user"
}

variable "business_unit" {
  description = "Business unit responsible for the resource"
  type        = string
  default     = "engineering"
}

variable "application_name" {
  description = "Application name for resource categorization"
  type        = string
  default     = "rds-application"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}