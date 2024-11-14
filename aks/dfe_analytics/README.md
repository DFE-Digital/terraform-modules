# DfE Analytics
Create resources in Google cloud Bigquery and provides the required variables to applications so they can send events.

## Usage
### Reuse existing dataset and events table

```hcl
provider "google" {
  project = "apply-for-qts-in-england"
}

module "dfe_analytics" {
  source = "./vendor/modules/dfe-terraform-modules//aks/dfe_analytics"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = var.environment
  gcp_dataset           = "events_${var.config}"
}
```

Note: this will create a new appender service account. The old service account AND the permission on the dataset must both be deleted manually afterwards.

### Create new dataset and events table
Use for a new environment. To get the values for `gcp_taxonomy_id` and `gcp_policy_tag_id` see [Taxonomy and policy tag](#taxonomy-and-policy-tag).

```hcl
provider "google" {
  project = "apply-for-qts-in-england"
}

module "dfe_analytics" {
  source = "./vendor/modules/dfe-terraform-modules//aks/dfe_analytics"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = var.environment
  gcp_keyring           = "afqts-key-ring"
  gcp_key               = "afqts-key"
  gcp_taxonomy_id       = 5456044749211275650
  gcp_policy_tag_id     = 2399328962407973209
}
```

## Configure application
### Enable in Ruby
```ruby
DfE::Analytics.configure do |config|
...
  config.azure_federated_auth = ENV.include? "GOOGLE_CLOUD_CREDENTIALS"
end
```

### Enable in .NET
```cs
builder.Services.AddDfeAnalytics()
    .UseFederatedAksBigQueryClientProvider();
```
Ensure the `ProjectNumber`, `WorkloadIdentityPoolName`, `WorkloadIdentityPoolProviderName` and `ServiceAccountEmail` configuration keys are populated within the `DfeAnalytics` configuration section.

### Variables
The application requires these environment variables:
- BIGQUERY_PROJECT_ID
- BIGQUERY_TABLE_NAME
- BIGQUERY_DATASET
- GOOGLE_CLOUD_CREDENTIALS
Each variable is available as a separate [output](tfdocs#outputs). For convenience, the `variables_map` output provides them all:

```hcl
module "application_configuration" {
  source = "./vendor/modules/dfe-terraform-modules//aks/application_configuration"
  ...
  secret_variables = merge(
    module.dfe_analytics.variables_map,
    {
      ...
    }
  )
}
```

### Enable on each app that requires it
```hcl
module "worker_application" {
  source = "./vendor/modules/dfe-terraform-modules//aks/application"
  ...
  enable_gcp_wif = true
}
```

## Authentication - Command line
The user should have Owner role on the Google project.

- Run `gcloud auth application-default login`
- Run terraform

## Authentication - Github actions
We set up workfload identity federation on the Google side and configure the workflow. The user should have Owner role on the Google project. This is done once per repository.

- Run the `authorise_workflow.sh` located in *aks/dfe_analytics*:
  ```
  ./authorise_workflow.sh PROJECT_ID REPO
  ```
  Example:
  ```
  ./authorise_workflow.sh apply-for-qts-in-england apply-for-qualified-teacher-status
  ```
- The script shows the *permissions* and *google-github-actions/auth step* to add to the workflow job
- Adding the permission removes the [default token permissions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication#permissions-for-the-github_token), which may be an issue for some actions that rely on them. For example, the [marocchino/sticky-pull-request-comment](https://github.com/marocchino/sticky-pull-request-comment) action requires `pull-requests: write`. It must then be added explicitly.
- Run the workflow

## Taxonomy and policy tag
The user should have Owner role on the Google project.

- Authenticate: `gcloud auth application-default login`
- Get projects list: `gcloud projects list`
- Select project e.g.: `gcloud config set project apply-for-qts-in-england`
- Get taxonomies list:
  ```
  gcloud data-catalog taxonomies list --location=europe-west2 --format="value(name)"
  ```
  The path contains the taxonomy id as a number e.g. 5456044749211275650
- Get policy tags e.g.:
  ```
  gcloud data-catalog taxonomies policy-tags list --taxonomy="projects/apply-for-qts-in-england/locations/europe-west2/taxonomies/5456044749211275650" --location="europe-west2" --filter="displayName:hidden" --format="value(name)"
  ```
  The path contains the policy tag id as a number e.g. 2399328962407973209
