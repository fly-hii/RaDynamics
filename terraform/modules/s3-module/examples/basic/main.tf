# Basic S3 Module Example
# This example demonstrates the minimal configuration required for the S3 module

module "s3-module_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-s3-module"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "s3-module-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "S3 Example"
  }
}