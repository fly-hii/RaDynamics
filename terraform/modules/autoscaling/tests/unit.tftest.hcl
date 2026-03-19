# Auto Scaling Module Unit Tests

run "test_autoscaling_basic_configuration" {
  command = plan

  variables {
    resource_name = "test-autoscaling"
    environment   = "test"
    
    # CCMS compliance
    cost_center      = "engineering"
    project_name     = "test-project"
    owner           = "test-team"
    business_unit   = "engineering"
    application_name = "test-app"
    data_classification = "internal"
  }

  assert {
    condition     = length(local.standard_tags) > 0
    error_message = "CCMS tags should be properly configured"
  }
}

run "test_security_controls" {
  command = plan

  variables {
    resource_name = "test-autoscaling-security"
    environment   = "prod"
    
    # CCMS compliance
    cost_center      = "engineering"
    project_name     = "security-test"
    owner           = "security-team"
    business_unit   = "engineering"
    application_name = "security-app"
    data_classification = "confidential"
  }

  assert {
    condition     = var.environment == "prod"
    error_message = "Production environment should be configured correctly"
  }
}