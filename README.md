# Terraform modules

Shared modules used by various DfE services.

## Modules

- [aks/application](aks/application)
- [aks/application_configuration](aks/application_configuration)
- [aks/cluster_data](aks/cluster_data)
- [aks/dfe_analytics](aks/dfe_analytics)
- [aks/job_configuration](aks/job_configuration)
- [aks/postgres](aks/postgres)
- [aks/redis](aks/redis)
- [aks/secrets](aks/secrets)
- [dns/records](dns/records)
- [dns/zones](dns/zones)
- [domains/environment_domains](domains/environment_domains)
- [domains/infrastructure](domains/infrastructure)
- [monitoring/statuscake](monitoring/statuscake)

## Example deployment

The [Example Rails deployment](EXAMPLE.md) document outlines the minimum steps required to set up a Rails application deployed using AKS.

## Release Process

### Git References
We use three git references to manage and promote new features:

#### `main` branch
All new features are added here first. This branch is used in environments with the lowest risk, such as review apps, to quickly test new features, catch errors early, and minimise the impact of bugs.

#### `testing` tag
A pre-release is generated every week that includes any new features in `main` from the past week. This tag is automatically updated and used in low-risk environments like development or QA. This allows us to catch errors in production-like environments and keep the impact of bugs low.

#### `stable` tag
A release is created that includes the features which were in the `testing` phase the previous week. This tag is automatically updated and used in higher-risk environments like production or preproduction. This ensures that only thoroughly tested features are deployed.

### Promotion Process
Let's assume the `stable` tag points to `v0.x.0` and `testing` points to `v0.y.0`. You can view the tags and their commit IDs [in the tags list](https://github.com/DFE-Digital/terraform-modules/tags).

#### To promote `testing` to `stable`:
1. Delete the current pre-release pointing to `v0.y.0`
1. Create a new release:
    - Select `Draft new release`
    - Click `Choose a tag` and enter `v0.y.0`
    - Select `Previous tag` `v0.x.0`
    - Click `Generate release notes`
    - Check the `Set as the latest release` box
    - Click `Publish release`

#### To promote new commits in `main` to `testing`:
If there are new commits in `main` that you want to promote to `testing`, increment `v0.y.0` to `v0.z.0`, then create a new pre-release:
1. Select `Draft new release`
1. Click `Choose a tag` and enter `v0.z.0`
1. Click `Create new tag`
1. Select the `Previous tag` `v0.y.0`
1. Click `Generate release notes`
1. Check the `Set as a pre-release` box
1. Click `Publish release`

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
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.19.0 markdown /terraform-docs > tfdocs.md
```
