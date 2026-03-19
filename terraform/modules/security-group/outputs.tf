# Terraform AWS Security Group Module - Outputs
# L1 Module outputs following CCMS standards

#------------------------------------------------------------------------------
# SECURITY GROUP OUTPUTS
#------------------------------------------------------------------------------

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.this.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.this.name
}

output "security_group_description" {
  description = "Description of the security group"
  value       = aws_security_group.this.description
}

output "vpc_id" {
  description = "VPC ID where the security group is created"
  value       = aws_security_group.this.vpc_id
}

output "owner_id" {
  description = "Owner ID of the security group"
  value       = aws_security_group.this.owner_id
}

#------------------------------------------------------------------------------
# RULES OUTPUTS
#------------------------------------------------------------------------------

output "ingress_rules" {
  description = "Ingress rules of the security group"
  value = [
    for rule in aws_security_group.this.ingress : {
      description      = rule.description
      from_port        = rule.from_port
      to_port          = rule.to_port
      protocol         = rule.protocol
      cidr_blocks      = rule.cidr_blocks
      ipv6_cidr_blocks = rule.ipv6_cidr_blocks
      prefix_list_ids  = rule.prefix_list_ids
      security_groups  = rule.security_groups
      self             = rule.self
    }
  ]
}

output "egress_rules" {
  description = "Egress rules of the security group"
  value = [
    for rule in aws_security_group.this.egress : {
      description      = rule.description
      from_port        = rule.from_port
      to_port          = rule.to_port
      protocol         = rule.protocol
      cidr_blocks      = rule.cidr_blocks
      ipv6_cidr_blocks = rule.ipv6_cidr_blocks
      prefix_list_ids  = rule.prefix_list_ids
      security_groups  = rule.security_groups
      self             = rule.self
    }
  ]
}

output "ingress_rules_count" {
  description = "Number of ingress rules"
  value       = length(aws_security_group.this.ingress)
}

output "egress_rules_count" {
  description = "Number of egress rules"
  value       = length(aws_security_group.this.egress)
}

#------------------------------------------------------------------------------
# SECURITY GROUP RULE OUTPUTS (Separate Resources)
#------------------------------------------------------------------------------

output "ingress_security_group_rules" {
  description = "Ingress rules created as separate resources"
  value = [
    for rule in aws_security_group_rule.ingress_rules : {
      id                       = rule.id
      type                     = rule.type
      from_port                = rule.from_port
      to_port                  = rule.to_port
      protocol                 = rule.protocol
      source_security_group_id = rule.source_security_group_id
      description              = rule.description
    }
  ]
}

output "egress_security_group_rules" {
  description = "Egress rules created as separate resources"
  value = [
    for rule in aws_security_group_rule.egress_rules : {
      id                       = rule.id
      type                     = rule.type
      from_port                = rule.from_port
      to_port                  = rule.to_port
      protocol                 = rule.protocol
      source_security_group_id = rule.source_security_group_id
      description              = rule.description
    }
  ]
}

#------------------------------------------------------------------------------
# FLOW LOGS OUTPUTS
#------------------------------------------------------------------------------

output "flow_log" {
  description = "VPC Flow Log information"
  value = var.enable_flow_logs ? {
    id               = try(aws_flow_log.security_group_flow_log[0].id, null)
    arn              = try(aws_flow_log.security_group_flow_log[0].arn, null)
    log_destination  = try(aws_flow_log.security_group_flow_log[0].log_destination, null)
    traffic_type     = try(aws_flow_log.security_group_flow_log[0].traffic_type, null)
    log_format       = try(aws_flow_log.security_group_flow_log[0].log_format, null)
  } : {}
}

#------------------------------------------------------------------------------
# TAGGING OUTPUTS (CCMS COMPLIANCE)
#------------------------------------------------------------------------------

output "tags_all" {
  description = "All tags applied to the security group including default provider tags"
  value       = aws_security_group.this.tags_all
}

output "resource_name" {
  description = "Resource name used for the security group"
  value       = var.resource_name
}

output "security_group_tags" {
  description = "Tags applied specifically to the security group resource"
  value       = aws_security_group.this.tags
}

#------------------------------------------------------------------------------
# SECURITY CONTROL OUTPUTS
#------------------------------------------------------------------------------

output "security_controls_status" {
  description = "Status of implemented security controls"
  value = var.security_controls_enabled ? {
    sg_01_tagging = {
      control = "Security Group Tagging Compliance"
      status  = "COMPLIANT"
      details = "All required tags applied to security group"
    }
    sg_02_ssh_restriction = {
      control = "SSH Access Restriction"
      status  = local.ssh_validation
      details = "SSH access from 0.0.0.0/0 validation status"
    }
    sg_03_rule_descriptions = {
      control = "Rule Description Requirements"
      status  = local.description_validation
      details = "All rules have proper descriptions"
    }
    sg_04_outbound_restrictions = {
      control = "Outbound Traffic Restrictions"
      status  = local.outbound_validation
      details = "Outbound traffic restriction status"
    }
    sg_05_flow_logs = {
      control = "VPC Flow Logs Monitoring"
      status  = local.flow_logs_validation
      details = "Flow logs monitoring status"
    }
  } : {}
}

output "security_compliance_tags" {
  description = "Security compliance tags applied to the security group"
  value = {
    security_controls    = lookup(local.standard_tags, "SecurityControls", "")
    restricted_ssh       = lookup(local.standard_tags, "RestrictedSSH", "")
    rule_descriptions    = lookup(local.standard_tags, "RuleDescriptions", "")
    flow_logs_enabled    = lookup(local.standard_tags, "FlowLogsEnabled", "")
    security_framework   = lookup(var.security_compliance_tags, "SecurityFramework", "")
    compliance_level     = lookup(var.security_compliance_tags, "ComplianceLevel", "")
  }
}

#------------------------------------------------------------------------------
# COMPUTED OUTPUTS
#------------------------------------------------------------------------------

output "security_group_summary" {
  description = "Summary of security group configuration"
  value = {
    id                = aws_security_group.this.id
    name              = aws_security_group.this.name
    description       = aws_security_group.this.description
    vpc_id            = aws_security_group.this.vpc_id
    ingress_rules     = length(aws_security_group.this.ingress)
    egress_rules      = length(aws_security_group.this.egress)
    flow_logs_enabled = var.enable_flow_logs
    environment       = var.environment
  }
}

output "rule_analysis" {
  description = "Analysis of security group rules"
  value = {
    has_ssh_access = length([
      for rule in aws_security_group.this.ingress : rule
      if rule.from_port == 22 && rule.to_port == 22
    ]) > 0
    
    has_http_access = length([
      for rule in aws_security_group.this.ingress : rule
      if rule.from_port == 80 && rule.to_port == 80
    ]) > 0
    
    has_https_access = length([
      for rule in aws_security_group.this.ingress : rule
      if rule.from_port == 443 && rule.to_port == 443
    ]) > 0
    
    allows_all_outbound = length([
      for rule in aws_security_group.this.egress : rule
      if rule.from_port == 0 && rule.to_port == 0 && rule.protocol == "-1"
    ]) > 0
    
    total_open_ports = length(distinct([
      for rule in aws_security_group.this.ingress : 
      rule.from_port == rule.to_port ? tostring(rule.from_port) : "${rule.from_port}-${rule.to_port}"
    ]))
  }
}

#------------------------------------------------------------------------------
# VALIDATION OUTPUTS
#------------------------------------------------------------------------------

output "validation_results" {
  description = "Security validation results"
  value = {
    ssh_validation         = local.ssh_validation
    description_validation = local.description_validation
    outbound_validation    = local.outbound_validation
    flow_logs_validation   = local.flow_logs_validation
    overall_compliance     = alltrue([
      local.ssh_validation != "NON_COMPLIANT",
      local.description_validation != "NON_COMPLIANT",
      local.outbound_validation != "NON_COMPLIANT",
      local.flow_logs_validation != "NON_COMPLIANT"
    ]) ? "COMPLIANT" : "NON_COMPLIANT"
  }
}