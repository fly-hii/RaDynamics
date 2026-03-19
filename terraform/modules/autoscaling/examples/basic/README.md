# Auto Scaling Module Basic Example

This example demonstrates the basic usage of the Auto Scaling module with minimal configuration.

## Usage

```hcl
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
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |