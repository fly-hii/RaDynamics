# Basic Auto Scaling Module Example
# This example demonstrates the minimal configuration required for the Auto Scaling module

module "autoscaling_basic" {
  source = "../../"
  
  # Required variables
  resource_name = "example-autoscaling"
  environment   = "dev"
  
  # CCMS compliance variables
  cost_center      = "engineering"
  project_name     = "autoscaling-example"
  owner           = "platform-team"
  business_unit   = "engineering"
  application_name = "example-app"
  data_classification = "internal"
  
  # Additional tags
  additional_tags = {
    Example     = "basic"
    Department  = "Engineering"
    Team        = "Platform"
    Purpose     = "Auto Scaling Example"
  }
}