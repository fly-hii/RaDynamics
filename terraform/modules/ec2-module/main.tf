# Terraform AWS EC2 Module - Main Configuration
# L1 Module for EC2 Instance provisioning with security compliance

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-ec2-module"
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
    # AWS region validation
    valid_regions = [
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1"
    ]
    
    # Instance type validation for different environments
    allowed_instance_types = {
      dev  = ["t3.micro", "t3.small", "t3.medium", "t3.large"]
      test = ["t3.small", "t3.medium", "t3.large", "t3.xlarge"]
      prod = ["t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge", "m5.large", "m5.xlarge", "m5.2xlarge"]
    }
    
    # Security requirements by environment
    security_requirements = {
      encryption_required = var.environment == "prod" ? true : var.require_encryption
      imdsv2_required    = var.environment == "prod" ? true : var.enforce_imdsv2
      public_ip_allowed  = var.environment == "prod" ? false : true
    }
  }
}

# Data sources for AMI and availability zones
data "aws_ami" "this" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami_name_filters
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "selected" {
  count = var.subnet_id != null ? 1 : 0
  id    = var.subnet_id
}

# Local values for configuration and tagging
locals {
  # Determine AMI ID
  ami_id = var.ami_id != null ? var.ami_id : (
    length(data.aws_ami.this) > 0 ? data.aws_ami.this[0].id : null
  )

  # Availability zone selection
  availability_zone = var.availability_zone != null ? var.availability_zone : (
    var.subnet_id != null ? data.aws_subnet.selected[0].availability_zone :
    data.aws_availability_zones.available.names[0]
  )

  # Standard tags following CCMS requirements with Security Controls
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.resource_name
      Module      = "terraform-aws-l1-ec2"
      Environment = var.environment
      Component   = "ec2-instance"
      # Security Control EC2-15: Resource Tagging Compliance
      SecurityControls      = "EC2-01,EC2-02,EC2-05,EC2-06,EC2-07"
      EncryptionEnabled     = var.root_block_device_encrypted ? "true" : "false"
      IMDSv2Enforced        = var.metadata_options_http_tokens == "required" ? "true" : "false"
      TerminationProtection = var.disable_api_termination ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )

  # User data template processing
  user_data_rendered = var.user_data_template != null ? base64encode(templatefile(
    "${path.module}/templates/${var.user_data_template}",
    var.user_data_variables
  )) : var.user_data_base64
}

# EC2 Instance Resource
resource "aws_instance" "this" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  availability_zone      = local.availability_zone

  # IAM instance profile
  iam_instance_profile = var.iam_instance_profile_name

  # User data
  user_data_base64 = local.user_data_rendered

  # Storage configuration (Security Control EC2-01: EBS Encryption at Rest)
  root_block_device {
    volume_type           = var.root_block_device_volume_type
    volume_size           = var.root_block_device_volume_size
    iops                  = var.root_block_device_iops
    throughput            = var.root_block_device_throughput
    encrypted             = var.root_block_device_encrypted # Security Control EC2-01
    kms_key_id            = var.root_block_device_kms_key_id
    delete_on_termination = var.root_block_device_delete_on_termination
  }

  # Additional EBS block devices (Security Control EC2-01: EBS Encryption at Rest)
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices

    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = ebs_block_device.value.volume_size
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true) # Security Control EC2-01
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", var.root_block_device_kms_key_id)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  # Network configuration (Security Control EC2-05: Private Network Isolation)
  associate_public_ip_address = var.associate_public_ip_address # Default: false for security
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips

  # Monitoring and maintenance (Security Control EC2-07: CloudWatch Detailed Monitoring)
  monitoring                           = var.enable_detailed_monitoring
  disable_api_termination              = var.disable_api_termination # Security Control EC2-06
  disable_api_stop                     = var.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # Placement configuration
  placement_group            = var.placement_group
  placement_partition_number = var.placement_partition_number
  tenancy                    = var.tenancy
  host_id                    = var.host_id

  # Credit specification for burstable instances
  dynamic "credit_specification" {
    for_each = var.cpu_credits != null ? [var.cpu_credits] : []

    content {
      cpu_credits = credit_specification.value
    }
  }

  # Metadata options (Security Control EC2-02: IMDSv2 Enforcement)
  metadata_options {
    http_endpoint               = var.metadata_options_http_endpoint
    http_tokens                 = var.metadata_options_http_tokens # Required for IMDSv2
    http_put_response_hop_limit = var.metadata_options_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options_instance_metadata_tags
  }

  # Enclave options
  dynamic "enclave_options" {
    for_each = var.enable_nitro_enclaves ? [1] : []

    content {
      enabled = var.enable_nitro_enclaves
    }
  }

  # Lifecycle management
  lifecycle {
    prevent_destroy = false  # Explicitly allow destruction
    ignore_changes = [
      ami,
      user_data_base64,
    ]
  }

  tags        = local.standard_tags
  volume_tags = local.standard_tags
}

# Elastic IP Association (optional)
resource "aws_eip_association" "this" {
  count = var.associate_elastic_ip && var.elastic_ip_allocation_id != null ? 1 : 0

  instance_id   = aws_instance.this.id
  allocation_id = var.elastic_ip_allocation_id
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.resource_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization (Security Control EC2-09)"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.this.id
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "EC2_09_Security_Monitoring"
      AlarmType       = "cpu_utilization"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "status_check" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.resource_name}-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors ec2 status check (Security Control EC2-09)"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.this.id
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "EC2_09_Security_Monitoring"
      AlarmType       = "status_check"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control EC2-01: Validate encryption
  encryption_validation = var.require_encryption ? (
    var.root_block_device_encrypted ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control EC2-02: Validate IMDSv2
  imdsv2_validation = var.enforce_imdsv2 ? (
    var.metadata_options_http_tokens == "required" ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control EC2-05: Validate private network
  network_validation = var.environment == "prod" ? (
    var.associate_public_ip_address == false ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DEV_ENVIRONMENT"

  # Security Control EC2-06: Validate termination protection
  termination_protection_validation = var.environment == "prod" && var.enable_termination_protection_prod ? (
    var.disable_api_termination == true ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "NOT_REQUIRED"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0

  triggers = {
    encryption_status             = local.encryption_validation
    imdsv2_status                 = local.imdsv2_validation
    network_status                = local.network_validation
    termination_protection_status = local.termination_protection_validation
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Security Controls Validation Report:"
      echo "EC2-01 Encryption: ${local.encryption_validation}"
      echo "EC2-02 IMDSv2: ${local.imdsv2_validation}"
      echo "EC2-05 Network: ${local.network_validation}"
      echo "EC2-06 Termination Protection: ${local.termination_protection_validation}"
    EOT
  }
}