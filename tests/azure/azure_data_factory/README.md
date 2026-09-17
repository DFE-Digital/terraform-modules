# Azure Data Factory Terratest

Scenarios are Terraform configurations used by Terratest.

The current tests run `terraform init` and `terraform validate` and `terraform apply` for the examples in the `tests/azure/azure_data_factory` directory.
Resources are created, tested, then destroyed (even on failure to create fully) when Terratest is run.

More scenarios can be added by creating a new directory with sample Terraform and associating tests. See [Terratest](https://terratest.gruntwork.io/docs/) for more information.

## Run
Change to the TSC development subscription (key vault and resource group pre-reqs are setup there)

```
az account set --subscription <subscription>
cd ./tests/azure/azure_data_factory
```

```powershell
go mod tidy
go test ./...
```

To run a specific scenario:

```powershell
go test -run TestTerraformScenarios/base -v
```
