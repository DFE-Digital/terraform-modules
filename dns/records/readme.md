# DNS records

Terraform code for managing Azure DNS records, currently A and CNAME records.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Variable
```json
{
  "hosted_zone": {
    "<zone 1 domain>": {
      "resource_group_name": "<resource group>", # Usually the same resource group for all domains of a service
      "a-records": {                             # List of A records
        "<name>": {
          "target": "<value>"
        },
        ...
      },
      "cnames": {                                # List of CNAME records
        "<name>": {
          "target": "<value>"
        },
        ...
      }
    }
  }
}
```

## Example
```json
{
  "hosted_zone": {
    "teacherservices.cloud": {
      "resource_group_name": "s189p01-tscdomains-rg",
      "a-records": {
        "test": {
          "target": "51.52.53.54"
        }
      },
      "cnames": {
        "_7008a420a798s7d6fs8df7": {
          "target": "_9867w9ef698hery8.vnfitht.acm-validations.aws",
          "ttl": 86400
        }
      }
    }
  }
}
```
