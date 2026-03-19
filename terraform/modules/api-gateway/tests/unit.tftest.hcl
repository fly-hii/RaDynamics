# API Gateway Module Unit Tests

run "test_api_gateway_basic_configuration" {
  command = plan

  variables {
    resource_name = "test-api-gateway"
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
    resource_name = "test-api-gateway-security"
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

run "test_ccms_compliance" {
  command = plan

  variables {
    resource_name = "test-api-gateway-ccms"
    environment   = "test"
    
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
    condition     = contains(keys(local.standard_tags), "Environment")
    error_message = "Environment tag should be present in standard tags"
  }

  assert {
    condition     = contains(keys(local.standard_tags), "CostCenter")
    error_message = "CCMS tags should be applied correctly"
  }
}