# Azure Data Factory Terratest

Scenarios are Terraform configurations used by Terratest. They run sequentially because scenarios may reuse the same Azure resource names and remote Terraform state.

The tests run `terraform init` and `terraform apply` for the registered scenarios in the `tests/azure/azure_data_factory` directory.
Resources are created, tested, then destroyed (even on failure to create fully) when Terratest is run.

To add a scenario:

1. Create a directory containing a complete Terraform fixture, including `main.tf` and provider configuration.
2. Add the scenario directory and its expected outputs to `terraformScenarios` in `azure_data_factory_test.go`.
3. Set `expectedAlertNames` to the alert metric keys expected for that fixture. Leave it empty when monitoring is disabled.

See [Terratest](https://terratest.gruntwork.io/docs/) for more information.

## Run
Change to the TSC development subscription (key vault and resource group pre-reqs are setup there)

```
az account set --subscription <subscription>
cd ./tests/azure/azure_data_factory
```

```sh
go mod tidy
go test ./...
```

To run a specific scenario:

```sh
go test -run TestTerraformScenarios/base -v
```
