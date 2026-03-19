# Terraform AWS Security Group Module - Main Configuration
# L1 Module for Security Group provisioning with security compliance

# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-security-group-module"
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
      restrict_ssh_access     = var.environment == "prod" ? true : var.restrict_ssh_access
      require_description     = var.environment == "prod" ? true : var.require_rule_descriptions
      block_all_outbound     = var.environment == "prod" ? false : var.block_all_outbound_default
      enable_flow_logs       = var.environment == "prod" ? true : var.enable_flow_logs
    }
  }
}

# Data sources
data "aws_vpc" "selected" {
  count = var.vpc_id != null ? 1 : 0
  id    = var.vpc_id
}

# Local values for configuration and tagging
locals {
  # Standard tags following CCMS requirements with Security Controls
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.resource_name
      Module      = "terraform-aws-l1-security-group"
      Environment = var.environment
      Component   = "security-group"
      # Security Control SG-01: Security Group Tagging Compliance
      SecurityControls    = "SG-01,SG-02,SG-03,SG-04,SG-05"
      RestrictedSSH       = local.config.security_requirements.restrict_ssh_access ? "true" : "false"
      RuleDescriptions    = local.config.security_requirements.require_description ? "true" : "false"
      FlowLogsEnabled     = local.config.security_requirements.enable_flow_logs ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )
}

# Security Group Resource
resource "aws_security_group" "this" {
  name_prefix = var.name_prefix != null ? var.name_prefix : "${var.resource_name}-"
  name        = var.name_prefix == null ? var.resource_name : null
  description = var.description
  vpc_id      = var.vpc_id

  # Dynamic ingress rules (Security Control SG-02: Ingress Rule Validation)
  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
    }
  }

  # Dynamic egress rules (Security Control SG-03: Egress Rule Validation)
  dynamic "egress" {
    for_each = var.egress_rules

    content {
      description      = lookup(egress.value, "description", null)
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
    }
  }

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
  }

  tags = local.standard_tags
}

# Security Group Rules (Alternative approach for complex scenarios)
resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_with_source_security_group_id)

  type                     = "ingress"
  from_port                = var.ingress_with_source_security_group_id[count.index].from_port
  to_port                  = var.ingress_with_source_security_group_id[count.index].to_port
  protocol                 = var.ingress_with_source_security_group_id[count.index].protocol
  source_security_group_id = var.ingress_with_source_security_group_id[count.index].source_security_group_id
  description              = lookup(var.ingress_with_source_security_group_id[count.index], "description", null)
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_rules" {
  count = length(var.egress_with_source_security_group_id)

  type                     = "egress"
  from_port                = var.egress_with_source_security_group_id[count.index].from_port
  to_port                  = var.egress_with_source_security_group_id[count.index].to_port
  protocol                 = var.egress_with_source_security_group_id[count.index].protocol
  source_security_group_id = var.egress_with_source_security_group_id[count.index].source_security_group_id
  description              = lookup(var.egress_with_source_security_group_id[count.index], "description", null)
  security_group_id        = aws_security_group.this.id
}

# VPC Flow Logs for Security Group monitoring (Security Control SG-05)
resource "aws_flow_log" "security_group_flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = var.flow_log_iam_role_arn
  log_destination = var.flow_log_destination_arn
  traffic_type    = var.flow_log_traffic_type
  vpc_id          = var.vpc_id

  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.resource_name}-flow-logs"
      SecurityControl = "SG_05_Flow_Logs_Monitoring"
      LogType         = "vpc_flow_logs"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control SG-02: Validate SSH access restrictions
  ssh_validation = local.config.security_requirements.restrict_ssh_access ? (
    length([
      for rule in var.ingress_rules : rule
      if rule.from_port == 22 && rule.to_port == 22 && 
         contains(lookup(rule, "cidr_blocks", []), "0.0.0.0/0")
    ]) == 0 ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control SG-03: Validate rule descriptions
  description_validation = local.config.security_requirements.require_description ? (
    length([
      for rule in concat(var.ingress_rules, var.egress_rules) : rule
      if lookup(rule, "description", null) == null || lookup(rule, "description", "") == ""
    ]) == 0 ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control SG-04: Validate outbound restrictions
  outbound_validation = var.block_all_outbound_default ? (
    length(var.egress_rules) == 0 ? "COMPLIANT" : "CONDITIONAL"
  ) : "DISABLED"

  # Security Control SG-05: Validate flow logs
  flow_logs_validation = var.enable_flow_logs ? (
    var.flow_log_destination_arn != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0

  triggers = {
    ssh_access_status     = local.ssh_validation
    description_status    = local.description_validation
    outbound_status       = local.outbound_validation
    flow_logs_status      = local.flow_logs_validation
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Security Group Controls Validation Report:"
      echo "SG-02 SSH Access Restriction: ${local.ssh_validation}"
      echo "SG-03 Rule Descriptions: ${local.description_validation}"
      echo "SG-04 Outbound Restrictions: ${local.outbound_validation}"
      echo "SG-05 Flow Logs: ${local.flow_logs_validation}"
    EOT
  }
}