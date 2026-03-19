# Basic IAM Role Module Example
# This example demonstrates the minimal configuration required for the IAM Role module

module "iam-role_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-iam-role"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "iam-role-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "IAM Role Example"
  }
}