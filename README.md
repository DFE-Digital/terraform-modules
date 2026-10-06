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
- [aks/redis_managed](aks/redis_managed)
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

Let's assume the `stable` tag points to `v0.x.0` for example `v0.19.0`

and `testing` points to `v0.y.0` for example `v.0.20.0`. 

You can view the tags and their commit IDs [in the tags list](https://github.com/DFE-Digital/terraform-modules/tags).

#### To promote `testing` to `stable`

1. Navigate to the [releases tab](https://github.com/DFE-Digital/terraform-modules/releases)
1. Delete the current pre-release pointing to testing at `v0.y.0`/`v0.20.0`
1. Create a new release:
    - Select `Draft new release`
    - On the `Tag:Select tag` dropdown enter `v0.y.0`/`v0.20.0`
    - On the new `Previous tag:` dropdown select `v0.x.0`/`v.0.19.0`
1. Click `Generate release notes`
    - Check the `Latest` release label box
    - Click `Publish release`

#### To promote new commits in `main` to `testing`

Check there have been new commits since the current testing branch in the commit history tab. This can be done by comparing the `testing` [commit tag](https://github.com/DFE-Digital/terraform-modules/tags) with the [commit history](https://github.com/DFE-Digital/terraform-modules/commits/main/). If `testing` is pointing to the latest commit then the below can be skipped.

If there are new commits in `main` that you want to promote to `testing`, follow the steps below to increment `v0.y.0`/`v.0.20.0` to `v0.z.0`/`v.21.0`:

1. Navigate to the [releases tab](https://github.com/DFE-Digital/terraform-modules/releases)
1. Select `Draft new release`
    - On the `Tag:Select tag` dropdown select `Create new tag` enter `v0.z.0`/`v0.21.0`
1. On the new `Previous tag:` dropdown select `v0.y.0`/`v.0.20.0`
1. Click `Generate release notes`
    - Check the `Pre-release` release label box
    - Click `Publish release`

## Updating [Terraform Docs]

Terraform Docs can be used in two ways:

### Install

- [Install Terraform Docs] according to the instructions for your platform.
- Run `terraform-docs [module]` for each module, where `module` is the path, for example:

  ```sh
  terraform-docs aks/application
  ```

[Terraform Docs]: https://terraform-docs.io/
[Install Terraform Docs]: https://terraform-docs.io/user-guide/installation/

### Run as a Docker container

- Run the following command in each module directory where the docs need to be updated:

```sh
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.19.0 markdown /terraform-docs > tfdocs.md
```
