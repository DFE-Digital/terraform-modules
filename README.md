# Terraform modules

Shared modules used by various DfE services.

## Modules

- [aks/application](aks/application)
- [aks/application_configuration](aks/application_configuration)
- [aks/cluster_data](aks/cluster_data)
- [aks/postgres](aks/postgres)
- [aks/redis](aks/redis)
- [dns/records](dns/records)
- [dns/zones](dns/zones)
- [domains/environment_domains](domains/environment_domains)
- [domains/infrastructure](domains/infrastructure)

## Release process

### Updating `testing` tag

Creating a pre-release for this repo will automatically update the `testing` tag used by pre-production apps.

### Updating `stable` tag

Creating a release for this repo will automatically update the `stable` tag used by production apps.
