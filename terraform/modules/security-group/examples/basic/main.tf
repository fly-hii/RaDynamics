# Basic Security Group Module Example
# This example demonstrates the minimal configuration required for the Security Group module

module "security-group_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-security-group"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "security-group-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "Security Group Example"
  }
}