# Azure Data Factory Terratest

Scenarios are Terraform configurations used by Terratest.

The current tests run `terraform init` and `terraform validate`; they do not create Azure resources.

## Run

```powershell
go mod tidy
go test ./...
```

To run a specific scenario:

```powershell
go test -run TestTerraformScenarios/base -v
```
