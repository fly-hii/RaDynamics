# Terraform AWS RDS Module - Main Configuration
# L1 Module for RDS Database provisioning with security compliance

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-rds-module"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
    LastModified  = formatdate("YYYY-MM-DD", timestamp())
    CostCenter    = var.cost_center
    Project       = var.project_name
    Owner         = var.owner
    BusinessUnit  = var.business_unit
    Application   = var.application_name
    DataClass     = var.data_classification
    Compliance    = "CCMS"
  }
}

# Local implementation of config validation
locals {
  # Configuration constants and validation
  config = {
    # Security requirements by environment
    security_requirements = {
      encryption_required        = var.environment == "prod" ? true : var.storage_encrypted
      backup_retention_days      = var.environment == "prod" ? max(var.backup_retention_period, 7) : var.backup_retention_period
      multi_az_required         = var.environment == "prod" ? true : var.multi_az
      deletion_protection       = var.environment == "prod" ? true : var.deletion_protection
      performance_insights      = var.environment == "prod" ? true : var.performance_insights_enabled
      monitoring_interval       = var.environment == "prod" ? 60 : var.monitoring_interval
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "database" {
  count = var.db_subnet_group_name == null ? 1 : 0
  
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Type = "database"
  }
}

# Local values for configuration and tagging
locals {
  # Standard tags following CCMS requirements with Security Controls
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.resource_name
      Module      = "terraform-aws-l1-rds"
      Environment = var.environment
      Component   = "rds-database"
      # Security Control RDS-01: RDS Tagging Compliance
      SecurityControls       = "RDS-01,RDS-02,RDS-03,RDS-04,RDS-05,RDS-06,RDS-07"
      EncryptionEnabled      = local.config.security_requirements.encryption_required ? "true" : "false"
      BackupRetentionDays    = tostring(local.config.security_requirements.backup_retention_days)
      MultiAZEnabled         = local.config.security_requirements.multi_az_required ? "true" : "false"
      DeletionProtection     = local.config.security_requirements.deletion_protection ? "true" : "false"
      PerformanceInsights    = local.config.security_requirements.performance_insights ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  count = var.db_subnet_group_name == null ? 1 : 0
  
  name       = "${var.resource_name}-subnet-group"
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.database[0].ids
  
  tags = merge(
    local.standard_tags,
    {
      Name      = "${var.resource_name}-subnet-group"
      Component = "db-subnet-group"
    }
  )
}

# DB Parameter Group
resource "aws_db_parameter_group" "this" {
  count = var.parameter_group_name == null ? 1 : 0
  
  family = var.parameter_group_family
  name   = "${var.resource_name}-params"
  
  dynamic "parameter" {
    for_each = var.parameters
    
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name      = "${var.resource_name}-params"
      Component = "db-parameter-group"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# DB Option Group (for engines that support it)
resource "aws_db_option_group" "this" {
  count = var.option_group_name == null && var.major_engine_version != null ? 1 : 0
  
  name                     = "${var.resource_name}-options"
  option_group_description = "Option group for ${var.resource_name}"
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version
  
  dynamic "option" {
    for_each = var.options
    
    content {
      option_name = option.value.option_name
      
      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name      = "${var.resource_name}-options"
      Component = "db-option-group"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "this" {
  # Basic Configuration
  identifier     = var.identifier != null ? var.identifier : var.resource_name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  # Database Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_throughput    = var.storage_throughput
  iops                  = var.iops
  
  # Database Credentials
  db_name  = var.db_name
  username = var.username
  password = var.password
  manage_master_user_password = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  
  # Network Configuration
  db_subnet_group_name   = var.db_subnet_group_name != null ? var.db_subnet_group_name : aws_db_subnet_group.this[0].name
  vpc_security_group_ids = var.vpc_security_group_ids
  port                   = var.port
  publicly_accessible    = var.publicly_accessible
  
  # Parameter and Option Groups
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.this[0].name
  option_group_name    = var.option_group_name != null ? var.option_group_name : (
    var.major_engine_version != null ? aws_db_option_group.this[0].name : null
  )
  
  # Security Configuration (Security Control RDS-02: Encryption at Rest)
  storage_encrypted = local.config.security_requirements.encryption_required
  kms_key_id       = var.kms_key_id
  
  # Backup Configuration (Security Control RDS-03: Backup and Recovery)
  backup_retention_period = local.config.security_requirements.backup_retention_days
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  copy_tags_to_snapshot  = true
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.resource_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # High Availability (Security Control RDS-04: Multi-AZ Deployment)
  multi_az               = local.config.security_requirements.multi_az_required
  availability_zone      = var.multi_az ? null : var.availability_zone
  
  # Monitoring Configuration (Security Control RDS-05: Enhanced Monitoring)
  monitoring_interval = local.config.security_requirements.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  
  # Performance Insights (Security Control RDS-06: Performance Monitoring)
  performance_insights_enabled          = local.config.security_requirements.performance_insights
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  
  # Security and Compliance
  deletion_protection = local.config.security_requirements.deletion_protection
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately = var.apply_immediately
  
  # Logging Configuration
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  # Lifecycle management
  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier,
    ]
  }
  
  tags = local.standard_tags
}

# Read Replica (optional)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0
  
  identifier             = "${var.resource_name}-read-replica"
  replicate_source_db    = aws_db_instance.this.identifier
  instance_class         = var.read_replica_instance_class != null ? var.read_replica_instance_class : var.instance_class
  publicly_accessible    = false
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  # Performance Insights for read replica
  performance_insights_enabled          = local.config.security_requirements.performance_insights
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  
  # Monitoring for read replica
  monitoring_interval = local.config.security_requirements.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn
  
  tags = merge(
    local.standard_tags,
    {
      Name      = "${var.resource_name}-read-replica"
      Component = "rds-read-replica"
    }
  )
}

# CloudWatch Alarms for monitoring (Security Control RDS-07)
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.resource_name}-database-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = var.alarm_actions
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.id
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.resource_name}-database-cpu"
      SecurityControl = "RDS_07_Performance_Monitoring"
      AlarmType       = "cpu_utilization"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.resource_name}-database-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connection_count_threshold
  alarm_description   = "This metric monitors RDS connection count"
  alarm_actions       = var.alarm_actions
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.id
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.resource_name}-database-connections"
      SecurityControl = "RDS_07_Performance_Monitoring"
      AlarmType       = "connection_count"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "database_freeable_memory" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.resource_name}-database-freeable-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.freeable_memory_threshold
  alarm_description   = "This metric monitors RDS freeable memory"
  alarm_actions       = var.alarm_actions
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.id
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.resource_name}-database-freeable-memory"
      SecurityControl = "RDS_07_Performance_Monitoring"
      AlarmType       = "freeable_memory"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control RDS-02: Validate encryption
  encryption_validation = local.config.security_requirements.encryption_required ? (
    aws_db_instance.this.storage_encrypted ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
  
  # Security Control RDS-03: Validate backup retention
  backup_validation = local.config.security_requirements.backup_retention_days >= 7 ? "COMPLIANT" : "NON_COMPLIANT"
  
  # Security Control RDS-04: Validate Multi-AZ
  multi_az_validation = var.environment == "prod" ? (
    aws_db_instance.this.multi_az ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DEV_ENVIRONMENT"
  
  # Security Control RDS-05: Validate monitoring
  monitoring_validation = local.config.security_requirements.monitoring_interval > 0 ? "COMPLIANT" : "NON_COMPLIANT"
  
  # Security Control RDS-06: Validate Performance Insights
  performance_insights_validation = local.config.security_requirements.performance_insights ? "COMPLIANT" : "DISABLED"
  
  # Security Control RDS-07: Validate deletion protection
  deletion_protection_validation = var.environment == "prod" ? (
    aws_db_instance.this.deletion_protection ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DEV_ENVIRONMENT"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0
  
  triggers = {
    encryption_status            = local.encryption_validation
    backup_status               = local.backup_validation
    multi_az_status             = local.multi_az_validation
    monitoring_status           = local.monitoring_validation
    performance_insights_status = local.performance_insights_validation
    deletion_protection_status  = local.deletion_protection_validation
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "RDS Security Controls Validation Report:"
      echo "RDS-02 Encryption: ${local.encryption_validation}"
      echo "RDS-03 Backup Retention: ${local.backup_validation}"
      echo "RDS-04 Multi-AZ: ${local.multi_az_validation}"
      echo "RDS-05 Monitoring: ${local.monitoring_validation}"
      echo "RDS-06 Performance Insights: ${local.performance_insights_validation}"
      echo "RDS-07 Deletion Protection: ${local.deletion_protection_validation}"
    EOT
  }
}