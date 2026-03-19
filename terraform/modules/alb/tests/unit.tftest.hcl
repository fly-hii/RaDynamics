# ALB Module Unit Tests

run "test_alb_basic_configuration" {
  command = plan

  variables {
    resource_name = "test-alb"
    environment   = "test"
    vpc_id        = "vpc-12345678"
    subnet_ids    = ["subnet-12345678", "subnet-87654321"]
    
    # CCMS compliance
    cost_center      = "engineering"
    project_name     = "test-project"
    owner           = "test-team"
    business_unit   = "engineering"
    application_name = "test-app"
    data_classification = "internal"
  }

  assert {
    condition     = aws_lb.main.name == "test-alb"
    error_message = "ALB name should match resource_name"
  }

  assert {
    condition     = aws_lb.main.load_balancer_type == "application"
    error_message = "Load balancer type should be application"
  }

  assert {
    condition     = aws_lb.main.enable_deletion_protection == false
    error_message = "Deletion protection should be disabled for test environment"
  }
}

run "test_security_controls" {
  command = plan

  variables {
    resource_name = "test-alb-security"
    environment   = "prod"
    vpc_id        = "vpc-12345678"
    subnet_ids    = ["subnet-12345678", "subnet-87654321"]
    
    # CCMS compliance
    cost_center      = "engineering"
    project_name     = "security-test"
    owner           = "security-team"
    business_unit   = "engineering"
    application_name = "security-app"
    data_classification = "confidential"
  }

  assert {
    condition     = aws_lb.main.enable_deletion_protection == true
    error_message = "Deletion protection should be enabled for production environment"
  }

  assert {
    condition     = length(aws_lb.main.access_logs) > 0
    error_message = "Access logs should be configured"
  }
}

run "test_ccms_compliance" {
  command = plan

  variables {
    resource_name = "test-alb-ccms"
    environment   = "test"
    vpc_id        = "vpc-12345678"
    subnet_ids    = ["subnet-12345678", "subnet-87654321"]
    
    # CCMS compliance
    cost_center      = "engineering"
    project_name     = "ccms-test"
    owner           = "ccms-team"
    business_unit   = "engineering"
    application_name = "ccms-app"
    data_classification = "internal"
    
    additional_tags = {
      TestTag = "test-value"
      Custom  = "custom-value"
    }
  }

  assert {
    condition     = aws_lb.main.tags["Environment"] == "test"
    error_message = "Environment tag should be set correctly"
  }

  assert {
    condition     = aws_lb.main.tags["TestTag"] == "test-value"
    error_message = "Additional tags should be merged correctly"
  }

  assert {
    condition     = aws_lb.main.tags["CostCenter"] == "engineering"
    error_message = "CCMS tags should be applied correctly"
  }
}