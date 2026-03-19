# EC2 Module Validation Tests
# Tests to validate security controls and functionality

variables {
  resource_name = "test-ec2-instance"
  environment   = "test"
  instance_type = "t3.micro"
  
  # Security configuration
  root_block_device_encrypted = true
  metadata_options_http_tokens = "required"
  associate_public_ip_address = false
  disable_api_termination = true
  
  # CCMS compliance
  cost_center = "engineering"
  project_name = "test-project"
  owner = "test-user"
  business_unit = "engineering"
  application_name = "test-app"
  data_classification = "internal"
}

run "validate_security_controls" {
  command = plan

  # Test EC2-01: EBS Encryption
  assert {
    condition = aws_instance.this.root_block_device[0].encrypted == true
    error_message = "EC2-01: Root block device must be encrypted"
  }

  # Test EC2-02: IMDSv2 Enforcement
  assert {
    condition = aws_instance.this.metadata_options[0].http_tokens == "required"
    error_message = "EC2-02: IMDSv2 must be enforced"
  }

  # Test EC2-05: Private Network Isolation
  assert {
    condition = aws_instance.this.associate_public_ip_address == false
    error_message = "EC2-05: Public IP should not be associated by default"
  }

  # Test EC2-06: Termination Protection
  assert {
    condition = aws_instance.this.disable_api_termination == true
    error_message = "EC2-06: Termination protection should be enabled"
  }
}

run "validate_ccms_compliance" {
  command = plan

  # Test required CCMS tags
  assert {
    condition = contains(keys(aws_instance.this.tags), "CreatedBy")
    error_message = "CCMS: CreatedBy tag is required"
  }

  assert {
    condition = contains(keys(aws_instance.this.tags), "Environment")
    error_message = "CCMS: Environment tag is required"
  }

  assert {
    condition = contains(keys(aws_instance.this.tags), "CostCenter")
    error_message = "CCMS: CostCenter tag is required"
  }

  assert {
    condition = contains(keys(aws_instance.this.tags), "SecurityControls")
    error_message = "CCMS: SecurityControls tag is required"
  }
}

run "validate_outputs" {
  command = plan

  # Test security control outputs
  assert {
    condition = output.security_controls_status != null
    error_message = "Security controls status output is required"
  }

  assert {
    condition = output.encryption_status != null
    error_message = "Encryption status output is required"
  }

  assert {
    condition = output.instance_id != null
    error_message = "Instance ID output is required"
  }
}