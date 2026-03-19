# Basic RDS Module Example
# This example demonstrates the minimal configuration required for the RDS module

module "rds_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-rds"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "rds-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "RDS Example"
  }
}