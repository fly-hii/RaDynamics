}

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-ecr-module"
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

# Standard tags following CCMS requirements with Security Controls
locals {
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.repository_name
      Module      = "terraform-aws-l1-ecr"
      Environment = var.environment
      Component   = "ecr-repository"
      # Security Control ECR-01: Image Security
      SecurityControls      = "ECR-01,ECR-02,ECR-03,ECR-04"
      EncryptionEnabled     = var.encryption_configuration != null ? "true" : "false"
      ScanOnPushEnabled     = var.image_scanning_configuration.scan_on_push ? "true" : "false"
      ImmutableTags         = var.image_tag_mutability == "IMMUTABLE" ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )
}

# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete        = var.force_delete

  # Image Scanning Configuration (Security Control ECR-01: Image Vulnerability Scanning)
  image_scanning_configuration {
    scan_on_push = var.image_scanning_configuration.scan_on_push
  }

  # Encryption Configuration (Security Control ECR-02: Encryption at Rest)
  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration != null ? [var.encryption_configuration] : []
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key        = encryption_configuration.value.kms_key
    }
  }

  tags = local.standard_tags
}

# ECR Repository Policy (Security Control ECR-03: Access Control)
resource "aws_ecr_repository_policy" "main" {
  count = var.repository_policy != null ? 1 : 0

  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy
}

# ECR Lifecycle Policy (Security Control ECR-04: Image Lifecycle Management)
resource "aws_ecr_lifecycle_policy" "main" {
  count = var.lifecycle_policy != null ? 1 : 0

  repository = aws_ecr_repository.main.name
  policy     = var.lifecycle_policy
}

# ECR Registry Scanning Configuration
resource "aws_ecr_registry_scanning_configuration" "main" {
  count = var.enable_registry_scanning ? 1 : 0

  scan_type = var.registry_scan_type

  dynamic "rule" {
    for_each = var.registry_scan_rules
    content {
      scan_frequency = rule.value.scan_frequency
      
      repository_filter {
        filter      = rule.value.repository_filter.filter
        filter_type = rule.value.repository_filter.filter_type
      }
    }
  }
}

# ECR Replication Configuration
resource "aws_ecr_replication_configuration" "main" {
  count = length(var.replication_configuration) > 0 ? 1 : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.replication_configuration
      content {
        dynamic "destination" {
          for_each = rule.value.destinations
          content {
            region      = destination.value.region
            registry_id = destination.value.registry_id
          }
        }

        dynamic "repository_filter" {
          for_each = rule.value.repository_filters
          content {
            filter      = repository_filter.value.filter
            filter_type = repository_filter.value.filter_type
          }
        }
      }
    }
  }
}

# ECR Registry Policy
resource "aws_ecr_registry_policy" "main" {
  count = var.registry_policy != null ? 1 : 0

  policy = var.registry_policy
}

# CloudWatch Log Group for ECR (Security Control ECR-02: Logging)
resource "aws_cloudwatch_log_group" "ecr" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/ecr/${var.repository_name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "ECR_02_Logging"
      LogType         = "ecr_repository"
    }
  )
}

# CloudWatch Alarms for ECR Repository Monitoring
resource "aws_cloudwatch_metric_alarm" "repository_size" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.repository_name}-repository-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RepositorySizeInBytes"
  namespace           = "AWS/ECR"
  period              = "86400"
  statistic           = "Average"
  threshold           = var.repository_size_threshold
  alarm_description   = "This metric monitors ECR repository size"
  alarm_actions       = var.alarm_actions

  dimensions = {
    RepositoryName = aws_ecr_repository.main.name
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "ECR_04_Monitoring"
      AlarmType       = "repository_size"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "image_count" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.repository_name}-image-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ImageCount"
  namespace           = "AWS/ECR"
  period              = "86400"
  statistic           = "Average"
  threshold           = var.image_count_threshold
  alarm_description   = "This metric monitors ECR repository image count"
  alarm_actions       = var.alarm_actions

  dimensions = {
    RepositoryName = aws_ecr_repository.main.name
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "ECR_04_Monitoring"
      AlarmType       = "image_count"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control ECR-01: Validate image scanning
  image_scanning_validation = var.security_controls_enabled ? (
    var.image_scanning_configuration.scan_on_push ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECR-02: Validate encryption
  encryption_validation = var.security_controls_enabled ? (
    var.encryption_configuration != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECR-03: Validate access control
  access_control_validation = var.security_controls_enabled ? (
    var.repository_policy != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECR-04: Validate lifecycle management
  lifecycle_validation = var.security_controls_enabled ? (
    var.lifecycle_policy != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0

  triggers = {
    image_scanning_status    = local.image_scanning_validation
    encryption_status        = local.encryption_validation
    access_control_status    = local.access_control_validation
    lifecycle_status         = local.lifecycle_validation
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "ECR Security Controls Validation Report:"
      echo "ECR-01 Image Scanning: ${local.image_scanning_validation}"
      echo "ECR-02 Encryption: ${local.encryption_validation}"
      echo "ECR-03 Access Control: ${local.access_control_validation}"
      echo "ECR-04 Lifecycle Management: ${local.lifecycle_validation}"
    EOT
  }
}