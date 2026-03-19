# Security Group Module Basic Example

This example demonstrates the basic usage of the Security Group module with minimal configuration.

## Usage

```hcl
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
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |