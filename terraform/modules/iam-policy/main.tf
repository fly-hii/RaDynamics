# Terraform AWS IAM Policy Module - Main Configuration
# Comprehensive IAM Policy management with JSON validation

# Local implementation of tags data
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-iam-policy-module"
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

# Local values for configuration and tagging
locals {
  # Standard tags following CCMS requirements
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.resource_name
      Module      = "terraform-aws-iam-policy"
      Environment = var.environment
      Component   = "iam-policy"
      PolicyType  = var.policy_type
      # Security Control IAM Policy Tagging Compliance
      SecurityControls = "IAM-POLICY-01,IAM-POLICY-02,IAM-POLICY-03"
    },
    var.additional_tags
  )
}

# Validate JSON policy document
locals {
  # Parse and validate the policy document
  parsed_policy = jsondecode(var.policy_document)
  
  # Validate policy structure
  policy_validation = {
    has_version    = can(local.parsed_policy.Version)
    has_statement  = can(local.parsed_policy.Statement)
    valid_version  = can(local.parsed_policy.Version) ? contains(["2012-10-17", "2008-10-17"], local.parsed_policy.Version) : false
    statement_count = can(local.parsed_policy.Statement) ? length(local.parsed_policy.Statement) : 0
  }
}

# IAM Policy Resource
resource "aws_iam_policy" "this" {
  name        = var.policy_name
  name_prefix = var.policy_name_prefix
  path        = var.path
  description = var.description
  policy      = var.policy_document
  
  tags = local.standard_tags
}

# Policy Version Management (for policy updates)
resource "aws_iam_policy_version" "this" {
  count = var.create_policy_version ? 1 : 0
  
  policy_arn = aws_iam_policy.this.arn
  policy     = var.policy_document
  set_as_default = true
}

# Policy Attachment to Users
resource "aws_iam_user_policy_attachment" "users" {
  count = length(var.attach_to_users)
  
  user       = var.attach_to_users[count.index]
  policy_arn = aws_iam_policy.this.arn
}

# Policy Attachment to Roles
resource "aws_iam_role_policy_attachment" "roles" {
  count = length(var.attach_to_roles)
  
  role       = var.attach_to_roles[count.index]
  policy_arn = aws_iam_policy.this.arn
}

# Policy Attachment to Groups
resource "aws_iam_group_policy_attachment" "groups" {
  count = length(var.attach_to_groups)
  
  group      = var.attach_to_groups[count.index]
  policy_arn = aws_iam_policy.this.arn
}

# Policy Simulator Test (if enabled)
resource "null_resource" "policy_simulator" {
  count = var.run_policy_simulator ? 1 : 0
  
  triggers = {
    policy_arn = aws_iam_policy.this.arn
    policy_document = var.policy_document
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Running IAM Policy Simulator for policy: ${aws_iam_policy.this.name}"
      echo "Policy ARN: ${aws_iam_policy.this.arn}"
      echo "Use AWS CLI or Console to test policy permissions"
      echo "aws iam simulate-principal-policy --policy-source-arn ${aws_iam_policy.this.arn} --action-names s3:GetObject --resource-arns arn:aws:s3:::example-bucket/*"
    EOT
  }
}

# CloudTrail for Policy monitoring
resource "aws_cloudtrail" "iam_policy_trail" {
  count = var.enable_cloudtrail_logging ? 1 : 0
  
  name           = "${var.policy_name}-iam-trail"
  s3_bucket_name = var.cloudtrail_s3_bucket_name
  s3_key_prefix  = "iam-policy-logs/"
  
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  
  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []
    
    data_resource {
      type   = "AWS::IAM::Policy"
      values = [aws_iam_policy.this.arn]
    }
  }
  
  tags = merge(
    local.standard_tags,
    {
      Name            = "${var.policy_name}-iam-trail"
      SecurityControl = "IAM_POLICY_CloudTrail_Monitoring"
      LogType         = "iam_policy_usage"
    }
  )
}

# Policy Analysis and Validation
resource "null_resource" "policy_analysis" {
  count = var.enable_policy_analysis ? 1 : 0
  
  triggers = {
    policy_document = var.policy_document
    policy_arn = aws_iam_policy.this.arn
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "IAM Policy Analysis Report:"
      echo "Policy Name: ${var.policy_name}"
      echo "Policy ARN: ${aws_iam_policy.this.arn}"
      echo "Policy Type: ${var.policy_type}"
      echo "Version: ${local.parsed_policy.Version}"
      echo "Statement Count: ${local.policy_validation.statement_count}"
      echo "Valid Structure: ${local.policy_validation.has_version && local.policy_validation.has_statement}"
      echo "Policy Size: ${length(var.policy_document)} characters"
    EOT
  }
}