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
### References
We maintain 3 git references and promote new features between them:
- All new features are immediately added to the `main` branch. Environments with lowest risk (like review apps) use this reference so new features are tested quickly, errors are caught earlier and bugs have minimal impact.
- A *pre-release* containing the new features from the past week (if there were any) is generated every week. It automatically updates the `testing` tag. Environments with low risk (like development or QA) use this reference so errors are caught in production like environments and bugs have low impact.
- A *release* containing the features which were in testing the week before is created at the same time. It automatically updates the `stable` tag. Environments with higher risk (like production or preproduction) use this reference so only features which were thoroughly tested are deployed.

### Process
Given the `stable` tag points to tag `v0.x.0` and `testing` points to `v0.y.0`. To promote `v0.y.0` to stable:
- Delete the current pre-release pointing to `v0.y.0`
- Create a new release with tag `v0.y.0`, target testing and generate changelog `v0.y.0 ... v0.x.0`
- If there are new commits in `main` that we want to promote to `testing`: increment `v0.y.0` to `v0.z.0`, then create a new pre-release with new tag `v0.z.0`, target main and generate changelog `v0.z.0 ... v0.y.0`

## Updating [Terraform Docs]

Terraform Docs can be used in two ways:
### Install

- [Install Terraform Docs] according to the instructions for your platform.
- Run `terraform-docs [module]` for each module, where `module` is the path, for example:
  ```sh
  $ terraform-docs aks/application
  ```

[Terraform Docs]: https://terraform-docs.io/
[Install Terraform Docs]: https://terraform-docs.io/user-guide/installation/

### Run as a Docker container

- Run the following command in each module directory where the docs need to be updated:

```sh
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs > tfdocs.md
```
