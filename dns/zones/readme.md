# DNS Zones

Terraform code for managing Azure DNS Zones and their default CAA and TXT records.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Variable
```json
{
  "hosted_zone": {
    "<zone 1 domain>": {
      "resource_group_name": "<resource group>", # Usually the same resource group for all domains of a service
      "caa_record_list": ["xxx", ...],           # CAA list valid domains for generating TLS certificates
      "txt_record_lists": {                      # Additional TXT records
        "<name>": ["x=y", ...]
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
      "caa_record_list": [
        "globalsign.com",
        "digicert.com"
      ],
      "txt_record_lists": {
        "@": [
          "v=spf1 -all",
          "_globalsign-domain-verification=XXXX"
        ]
      }
    }
  }
}
```
