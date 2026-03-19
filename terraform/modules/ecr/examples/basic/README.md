# Elastic Container Registry Module Basic Example

This example demonstrates the basic usage of the Elastic Container Registry module with minimal configuration.

## Usage

```hcl
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
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |