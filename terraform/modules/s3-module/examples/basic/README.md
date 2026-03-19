# S3 Module Basic Example

This example demonstrates the basic usage of the S3 module with minimal configuration.

## Usage

```hcl
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
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |