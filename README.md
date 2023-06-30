# Terraform modules

Shared modules used by various DfE services.

## Modules

- [aks/application](aks/application)
- [aks/application_configuration](aks/application_configuration)
- [aks/cluster_data](aks/cluster_data)
- [aks/postgres](aks/postgres)
- [aks/redis](aks/redis)
- [aks/secrets](aks/secrets)
- [dns/records](dns/records)
- [dns/zones](dns/zones)
- [domains/environment_domains](domains/environment_domains)
- [domains/infrastructure](domains/infrastructure)

## Example deployment

The [Example Rails deployment](EXAMPLE.md) document outlines the minimum steps required to set up a Rails application deployed using AKS.

## Release process

### Updating `testing` tag

Creating a pre-release for this repo will automatically update the `testing` tag used by pre-production apps.

### Updating `stable` tag

Creating a release for this repo will automatically update the `stable` tag used by production apps.

## Updating [Terraform Docs](https://terraform-docs.io/)

Run the following command in each module directory where the docs need to be updated:

```sh
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs > tfdocs.md
```
