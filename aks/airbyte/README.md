# AKS Airbyte

Terraform code for deploying Airbyte.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "airbyte" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/airbyte?ref=stable"

  blah = "blah"


}
```

### Monitoring

## Outputs

### `password`

The admin password of the user.

### `source_name`

The name of the source.

### `destination_name`

The name of the destination.
