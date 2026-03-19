# Basic Elastic Container Registry Module Example
# This example demonstrates the minimal configuration required for the Elastic Container Registry module

module "ecr_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-ecr"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "ecr-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "Elastic Container Registry Example"
  }
}