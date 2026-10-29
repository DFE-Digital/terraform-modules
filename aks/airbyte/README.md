# Airbyte
Create resources in Azure and Google cloud for airbyte to send data to BigQuery

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

# Configure a service to use Airbyte

This guide explains how to configure a service to replicate data from Azure PostgreSQL to Google BigQuery using Airbyte.

## Overview

The setup consists of the following steps. Each numbered step below matches this list.

1. Authenticate with Google Cloud (step 1).
2. Check the existing Google Cloud resources (step 2).
3. Create any missing Google Cloud resources, including the `Airbyte_workflow_IAM` role binding (step 3).
4. Create the Airbyte base resources and workspace (step 4).
5. Add the required secrets to Azure Key Vault (step 5).
6. Configure PostgreSQL logical replication (step 6).
7. Add the Airbyte Terraform provider, module, variables and locals (steps 7 to 9).
8. Add the application environment variables and secrets (steps 11 and 12). Step 10 is legacy and can be skipped.
9. Enable Airbyte in the application, if it is a Rails service (step 13).
10. Deploy and enable the Airbyte connection (step 14).
11. Validate the connection in the Airbyte UI (step 15).
12. Enable PostgreSQL monitoring (step 16).

Also read [.NET services](#net-services), [Review apps](#review-apps) and [Rollout order](#rollout-order).

## Prerequisites

Before starting, make sure:

- You have the `Owner` role on the relevant Google Cloud project.
- You know the target:
  - service repository
  - environment
  - Azure Kubernetes namespace
  - Google Cloud project
  - BigQuery project
- The service uses the shared Terraform modules from `teacher-services-cloud`.
- You have access to the relevant Azure Key Vault.
- You have agreed a deployment window with the service technical lead.
- DFE Analytics is on version 1.16.1 or higher.

> Enabling PostgreSQL logical replication can trigger several database server restarts. Agree a suitable time before merging the change.

## 1. Authenticate with Google Cloud

Run:

```shell
gcloud auth application-default login
```

Then:

1. Open the link provided by the command.
2. Select your DfE email address.
3. Select **Continue**.
4. Select **Continue** again.
5. Copy the provided code.
6. Paste the code into your terminal.

List the projects you can access:

```shell
gcloud projects list
```

Set the project used by subsequent commands:

```shell
gcloud config set project <PROJECT_ID>
```

Confirm the active account and project:

```shell
gcloud config list
```

## 2. Check the existing Google Cloud resources

Some of the required resources may already exist. Check them before running any create commands.

### 2.1 Get the project number

The project number is required when constructing Workload Identity Federation principal sets.

```shell
gcloud projects describe <PROJECT_ID> \
  --format="value(projectNumber)"
```

### 2.2 Get the Data Catalog taxonomy

```shell
gcloud data-catalog taxonomies list \
  --location=europe-west2 \
  --format="value(name)"
```

The returned path contains the taxonomy ID:

```text
projects/<PROJECT_ID>/locations/europe-west2/taxonomies/<TAXONOMY_ID>
```

Record the numeric `<TAXONOMY_ID>` for the Terraform configuration.

### 2.3 Get the `hidden` policy tag

```shell
gcloud data-catalog taxonomies policy-tags list \
  --taxonomy="projects/<PROJECT_ID>/locations/europe-west2/taxonomies/<TAXONOMY_ID>" \
  --location="europe-west2" \
  --filter="displayName:hidden" \
  --format="value(name)"
```

The returned path contains the policy tag ID:

```text
projects/<PROJECT_ID>/locations/europe-west2/taxonomies/<TAXONOMY_ID>/policyTags/<POLICY_TAG_ID>
```

Record the numeric `<POLICY_TAG_ID>` for the Terraform configuration.

### 2.4 Get the Cloud KMS key ring

```shell
gcloud kms keyrings list \
  --location=europe-west2 \
  --project=<PROJECT_ID>
```

Record the key ring name.

### 2.5 Get the Cloud KMS key

```shell
gcloud kms keys list \
  --location=europe-west2 \
  --keyring=<KEY_RING> \
  --project=<PROJECT_ID>
```

Record the key name.

### 2.6 Check the Workload Identity Pool

Each project should have a Workload Identity Pool named:

```text
azure-cip-identity-pool
```

List the pools:

```shell
gcloud iam workload-identity-pools list \
  --project=<PROJECT_ID> \
  --location=global
```

### 2.7 Check the Workload Identity Pool provider

Each project should have a provider named:

```text
azure-cip-oidc-provider
```

List the providers:

```shell
gcloud iam workload-identity-pools providers list \
  --project=<PROJECT_ID> \
  --location=global \
  --workload-identity-pool=azure-cip-identity-pool
```

The full provider resource name is used for Workload Identity Federation authentication.

### 2.8 Check the internal Airbyte dataset

Each BigQuery project requires a dataset named:

```text
airbyte_internal
```

Check whether it exists:

```shell
bq ls --project_id=<PROJECT_ID>
```

### 2.9 Check the custom role

> **Note:** The `Airbyte_workflow_IAM` custom role is required. The service's GitHub Actions identity must be bound to it (step 3.5), otherwise the deploy fails with `403` errors from Google Cloud IAM or Data Catalog (for example `Permission 'datacatalog.taxonomies.getIamPolicy' denied`).

Check whether the role exists:

```shell
gcloud iam roles describe Airbyte_workflow_IAM \
  --project=<PROJECT_ID>
```

If it exists, the response will look similar to:

```yaml
description: "Created on: 2025-09-24"
etag: BwZYx499999=
includedPermissions:
  - datacatalog.taxonomies.getIamPolicy
  - datacatalog.taxonomies.setIamPolicy
  - resourcemanager.projects.getIamPolicy
  - resourcemanager.projects.setIamPolicy
name: projects/<PROJECT_ID>/roles/Airbyte_workflow_IAM
stage: ALPHA
title: Airbyte Workflow IAM
```

If it does not exist, the command returns `NOT_FOUND`. Create it in step 3.4.

## 3. Create missing Google Cloud resources

Only create resources that are not already present.

### 3.1 Create the Workload Identity Pool

The preferred method is to use the existing script:

[create-gcp-workload-identity-pool.sh](https://github.com/DFE-Digital/teacher-services-analytics-cloud/blob/main/scripts/gcloud/create-gcp-workload-identity-pool.sh)

Alternatively, create it directly:

```shell
gcloud iam workload-identity-pools create "azure-cip-identity-pool" \
  --location="global" \
  --description="Azure CIP to GCP Workload Identity Pool" \
  --display-name="azure-cip-identity-pool" \
  --project=<PROJECT_ID>
```

### 3.2 Create the Workload Identity Pool provider

The preferred method is to use the existing script:

[create-gcp-workload-identity-pool-provider.sh](https://github.com/DFE-Digital/teacher-services-analytics-cloud/blob/main/scripts/gcloud/create-gcp-workload-identity-pool-provider.sh)

Alternatively, create it directly:

```shell
gcloud iam workload-identity-pools providers create-oidc \
  azure-cip-oidc-provider \
  --workload-identity-pool="azure-cip-identity-pool" \
  --issuer-uri="https://login.microsoftonline.com/9c7d9dd3-840c-4b3f-818e-552865082e16/v2.0" \
  --allowed-audiences="fb60f99c-7a34-4190-8149-302f77469936" \
  --location="global" \
  --attribute-mapping="google.subject=assertion.sub" \
  --project=<PROJECT_ID>
```

### 3.3 Create the internal Airbyte dataset

Create one `airbyte_internal` dataset per BigQuery project.

The dataset must:

- be located in `europe-west2`
- use the project Cloud KMS key
- apply a one-day default table expiry

```shell
bq --location=europe-west2 mk \
  --dataset \
  --default_kms_key=projects/<PROJECT_ID>/locations/europe-west2/keyRings/<KEY_RING>/cryptoKeys/<KEY> \
  --default_table_expiration=86400 \
  --description="Airbyte internal table - Only for Airbyte use" \
  <PROJECT_ID>:airbyte_internal
```

### 3.4 Create the custom IAM role

Skip this step if the role already exists (step 2.9).

The role ID is:

```text
Airbyte_workflow_IAM
```

Create it with:

```shell
gcloud iam roles create Airbyte_workflow_IAM \
  --project=<PROJECT_ID> \
  --title="Airbyte Workflow IAM" \
  --description="Created for the Airbyte workflow" \
  --permissions="resourcemanager.projects.getIamPolicy,resourcemanager.projects.setIamPolicy,datacatalog.taxonomies.getIamPolicy,datacatalog.taxonomies.setIamPolicy" \
  --stage=ALPHA
```

### 3.5 Add the custom role binding

This binding must be added for every service repository. It lets the service's GitHub Actions deploy set IAM policies on the taxonomy and project.

```shell
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --role="projects/<PROJECT_ID>/roles/Airbyte_workflow_IAM" \
  --member="principalSet://iam.googleapis.com/projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<WORKLOAD_IDENTITY_POOL>/attribute.repository/DFE-Digital/<REPOSITORY_NAME>"
```

Get the project number with:

```shell
gcloud projects describe <PROJECT_ID> --format='value(projectNumber)'
```

Use the same Workload Identity Pool that already holds the repository's other bindings. Those bindings grant these roles:

```text
BigQuery Data Owner
Cloud KMS Viewer
Data Catalog Viewer
Service Account Admin
```

Check the binding exists:

```shell
gcloud projects get-iam-policy <PROJECT_ID> \
  --flatten="bindings[].members" \
  --filter="bindings.role:Airbyte_workflow_IAM AND bindings.members:<REPOSITORY_NAME>" \
  --format="table(bindings.role, bindings.members)"
```

## 4. Create the Airbyte base resources

Each Kubernetes namespace has its own shared Airbyte base resources, including:

- Airbyte UI
- worker
- cron jobs
- supporting Airbyte services

Each consuming service then has its own Airbyte connection within the namespace workspace.

Ask the SD Infrastructure Operations team to do one of the following:

- create the Airbyte base resources for the namespace
- create a workspace in the existing namespace Airbyte deployment

The Airbyte infrastructure configuration is in:

[teacher-services-cloud/airbyte](https://github.com/DFE-Digital/teacher-services-cloud/tree/main/airbyte)

Once the workspace is available, record:

- the Airbyte server URL
- the workspace ID
- an application client ID
- an application client secret

## 5. Add the secrets to Azure Key Vault

Once the Airbyte workspace has been created, add the required secrets to the relevant Azure Key Vault.

Most services use the infrastructure Key Vault. For example:

- RTT production: `s189p01-rtt-pd-kv`
- ITTMS production: `s189p01-ittms-pd-inf-kv`

Some services retrieve the Airbyte credentials from the application Key Vault. In those services, only `AIRBYTE-CLIENT-ID` and `AIRBYTE-CLIENT-SECRET` need to be added there.

Add the following secrets:

- `AIRBYTE-CLIENT-ID`
- `AIRBYTE-CLIENT-SECRET`
- `AIRBYTE-WORKSPACE-ID`
- `AIRBYTE-REPLICATION-PASSWORD`
- `AIRBYTE-BQ-SA`

### `AIRBYTE-CLIENT-ID`

In the Airbyte UI, go to:

```text
Settings -> Applications -> Client ID
```

### `AIRBYTE-CLIENT-SECRET`

In the Airbyte UI, go to:

```text
Settings -> Applications -> Client Secret
```

### `AIRBYTE-WORKSPACE-ID`

Open the workspace in the Airbyte UI.

The workspace ID is the section of the URL immediately before `/settings`.

### `AIRBYTE-REPLICATION-PASSWORD`

Generate a password for the PostgreSQL replication user.

Follow the password standards used by the existing Airbyte-enabled services.

### `AIRBYTE-BQ-SA`

In Google Cloud, go to:

```text
IAM & Admin -> Service Accounts
```

Use the service account's complete email address.

The service account names vary, but commonly begin with `app-wif`. If no service account exists for that environment, use the next environments service account.

## 6. Configure PostgreSQL logical replication

> This change can trigger several database server restarts. Agree a deployment time with the service technical lead before merging it.

### 6.1 Add the Terraform variable

Add the following to `variables.tf`:

```hcl
variable "pg_airbyte_enabled" {
  type        = bool
  default     = false
  description = "Enable PostgreSQL logical replication for Airbyte"
}
```

### 6.2 Pass the setting to the PostgreSQL module

Update the service's PostgreSQL module:

```hcl
module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"

  # Existing configuration...

  use_airbyte = var.pg_airbyte_enabled
}
```

### 6.3 Enable logical replication for the environment

Add the following to the environment's `env.tfvars.json`:

```json
{
  "pg_airbyte_enabled": true
}
```

Deploy this change and allow the PostgreSQL restarts to complete before enabling the Airbyte connection.

## 7. Add the Airbyte Terraform provider

Update `terraform.tf`.

Add the Airbyte provider to the existing `required_providers` block:

```hcl
terraform {
  required_version = "<existing version>" # keep the version the service already pins

  required_providers {
    # Existing providers...

    airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.10.0"
    }
  }
}
```

Configure the provider:

```hcl
provider "airbyte" {
  server_url    = "${local.airbyte_server_url}/api/public/v1"
  client_id     = try(module.secrets.map.AIRBYTE-CLIENT-ID, "")
  client_secret = try(module.secrets.map.AIRBYTE-CLIENT-SECRET, "")
}
```

`local.airbyte_server_url` is defined in step 9. It is a local, rather than an inline string, because the provider, the Airbyte module and the application config all need the same URL.

Do not gate the credentials on `var.airbyte_enabled`. When `airbyte_enabled` changes from `true` to `false`, the Airbyte module is removed from the plan and Terraform must call the Airbyte API to delete the source, destination and connection. This only works if the provider still has valid credentials during that run. A gated provider receives empty credentials at that point and the destroy fails.

`try()` avoids the opposite problem. In environments where the Airbyte secrets have not been created, the lookup fails, `try()` returns `""`, and Terraform still plans and applies because no Airbyte resources need the provider.

> Remove Airbyte from an environment (set `airbyte_enabled` to `false` and apply) before deleting its Airbyte secrets from Key Vault.

> **Known gotcha:** many existing services still gate the credentials, for example `client_id = var.airbyte_enabled ? ... : ""`. With that pattern, destroying a review app or disabling Airbyte can fail because the provider has no credentials when it needs to delete the Airbyte resources. These services currently gate the provider and should be changed to the `try()` pattern above:
>
> - apply-for-qualified-teacher-status
> - apply-for-teacher-training
> - check-performance-data
> - claim-additional-payments-for-teaching
> - find-placement-schools
> - itt-mentor-services
> - npq-registration
> - publish-teacher-training
> - register-trainee-teachers
> - teaching-record-system
>
> `teacher-training-entitlement` and `register-early-career-teachers-public` already use `try()`.

If it is not already configured, add the Google provider:

```hcl
provider "google" {
  project = "<PROJECT_ID>"
}
```

Replace `<PROJECT_ID>` with the service's Google Cloud project ID.

## 8. Add the Airbyte module to Airbyte.tf

Add the Airbyte module to the service Terraform configuration.

Values marked with placeholders must be replaced with the values discovered in [step 2](#2-check-the-existing-google-cloud-resources). Services in the same Google Cloud project group share a taxonomy, policy tag, key ring and key, so check an existing service in the same group (for example its `airbyte.tf` or `dfe_analytics` module) and reuse its values rather than creating new ones.

This example is for a Rails service. For a .NET service see [.NET services](#net-services).

```hcl
module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = local.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  service_name          = var.service_name
  docker_image          = var.app_docker_image
  postgres_version      = var.postgres_version
  postgres_url          = module.postgres.url

  host_name     = module.postgres.host
  database_name = module.postgres.name

  workspace_id  = var.airbyte_enabled ? module.secrets.map.AIRBYTE-WORKSPACE-ID : null
  client_id     = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-ID : null
  client_secret = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-SECRET : null
  repl_password = var.airbyte_enabled ? module.secrets.map.AIRBYTE-REPLICATION-PASSWORD : null

  server_url = local.airbyte_server_url

  connection_status = var.connection_status

  cluster   = var.cluster
  namespace = var.namespace

  gcp_taxonomy_id   = "<TAXONOMY_ID>"
  gcp_policy_tag_id = "<POLICY_TAG_ID>"
  gcp_keyring       = "<KEY_RING>"
  gcp_key           = "<KEY>"

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  use_azure = var.deploy_azure_backing_services
  gcp_bq_sa = var.airbyte_enabled ? module.secrets.map.AIRBYTE-BQ-SA : null
}
```

The provider block and some variable names may already exist or may be implemented differently in the service. Search the repository and follow the existing conventions where they differ. Common differences:

- The secrets module may be named `infrastructure_secrets` (for example when it is declared with `key_vault_short = "inf"`) rather than `secrets`. Use whichever module reads the Key Vault holding the Airbyte secrets.
- Services without `local.environment` should use `var.environment`. For review apps `var.environment` is `review-<PR number>`, so each review app gets its own dataset and Airbyte resources.
- If the service has no dev/test Airbyte workspace secrets in place, `airbyte_enabled` must stay `false` for that environment, otherwise Terraform fails reading the Key Vault.
- The GCP values (`gcp_taxonomy_id`, `gcp_policy_tag_id`, `gcp_keyring`, `gcp_key`) are often already set on the `dfe_analytics` module. Move them into shared `locals` and reference them from both modules.

## 9. Add the Airbyte variables and locals to Airbyte.tf

Add the following variables:

```hcl
variable "airbyte_enabled" {
  type        = bool
  default     = false
  description = "Create the Airbyte source, destination and connection"
}

variable "connection_status" {
  type        = string
  default     = "inactive"
  description = "Airbyte connection status, either active or inactive"

  validation {
    condition     = contains(["active", "inactive"], var.connection_status)
    error_message = "connection_status must be either active or inactive."
  }
}
```

Add the required locals:

```hcl
locals {
  gcp_dataset_name = replace(
    "${var.service_short}_airbyte_${local.app_name_suffix}",
    "-",
    "_"
  )

  airbyte_server_url = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
}
```

Make sure the service's secrets module exposes the required Airbyte Key Vault secrets:

```hcl
module "secrets" {
  source = "./vendor/modules/aks//aks/secrets"

  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
}
```

## 10. Stream configuration (legacy, skip for new services)

New services do not need a stream configuration file. The module no longer uses the `connection_streams` input, and the streams are set up by the stream-update job (`rake dfe:analytics:airbyte_deploy_tasks` for Rails) using the DfE Analytics configuration.

Older services (apply-for-teacher-training, publish-teacher-training, find-placement-schools, itt-mentor-services, register-trainee-teachers) still pass `connection_streams` from an `airbyte_stream_config.json` file. It has no effect and can be removed along with the `connection_streams` local.

## 11. Add the application environment variables

Merge the following values into the service's application environment variables.

The exact implementation depends on how the service constructs its ConfigMap or environment variable map.

```hcl
{
  BIGQUERY_AIRBYTE_DATASET = var.airbyte_enabled
    ? local.gcp_dataset_name
    : null

  AIRBYTE_SERVER_URL = var.airbyte_enabled
    ? local.airbyte_server_url
    : null

  BIGQUERY_POLICY_TAGS = var.airbyte_enabled
    ? "{\"hidden\":\"projects/<PROJECT_ID>/locations/europe-west2/taxonomies/<TAXONOMY_ID>/policyTags/<POLICY_TAG_ID>\"}"
    : null

  # Optional. Only set by some services.
  AIRBYTE_INTERNAL_DATASET = var.airbyte_enabled
    ? "${local.gcp_dataset_name}_internal"
    : null
}
```

Replace:

- `<PROJECT_ID>`
- `<TAXONOMY_ID>`
- `<POLICY_TAG_ID>`

with the values for the target Google Cloud project.


## 12. Add the application secret variables

Merge the following into the service's secret environment variables, usually in application.tf:

```hcl
  secret_variables = merge({
    existing secrets
    existing secrets
    existing secrets
    existing secrets
    existing secrets
    existing secrets
    },
    {
      AIRBYTE_CONFIGURATION = var.airbyte_enabled ? jsonencode({
        SOURCE_ID      = module.airbyte[0].airbyte_source_id
        DESTINATION_ID = module.airbyte[0].airbyte_destination_id
        CONNECTION_ID  = module.airbyte[0].airbyte_connection_id
      }) : null
  })
```

This makes the Airbyte resource IDs available to the application.

## 13. Enable Airbyte in the Rails application (Rails services only)

`BIGQUERY_AIRBYTE_DATASET` (step 11) must be set for the application to detect Airbyte. Enable it in `config/initializers/dfe_analytics.rb`, limited to the environments that run Airbyte:

```ruby
# Perform airbyte checks on startup and allow airbyte config generation
config.airbyte_enabled = Rails.env.in?(%w[review]) && ENV["BIGQUERY_AIRBYTE_DATASET"].present?
```

Add each environment to the list as Airbyte is rolled out to it.

> .NET services do not use this initializer. See [.NET services](#net-services).


## 14. Enable Airbyte

Add the following to the environment's `env.tfvars.json`:

```json
{
  "pg_airbyte_enabled": true,
  "airbyte_enabled": true,
  "connection_status": "active"
}
```

Deploy the environment.

Setting `airbyte_enabled` to `true` creates:

- the Airbyte source
- the Airbyte destination
- the Airbyte connection
- the PostgreSQL replication slot
- the Google Cloud service account
- the service-specific BigQuery dataset
- the associated Google Cloud resources managed by the Airbyte module

Setting `connection_status` to `active` enables the connection so that it can be tested and run from the Airbyte UI.

## 15. Validate the connection in the Airbyte UI

Use the Airbyte Loop document to find the correct Airbyte URL for the namespace.

In the Airbyte UI:

1. Open the relevant workspace.
2. Select the service connection.
3. Check that the source and destination are configured correctly.
4. Open the **Schema** tab.
5. Check that the expected tables are present.
6. Check that the required tables are selected.
7. Select **Sync now**.

If no application tables are selected:

1. Select the `airbyte_heartbeat` table.
2. Select **Sync now**.
3. Confirm that the sync completes successfully.

After the sync completes, confirm that:

- the connection is active
- the sync completed successfully
- the expected tables appear in BigQuery
- the BigQuery tables use the expected encryption key
- policy tags have been applied where required

## 16. Enable PostgreSQL monitoring

If the service uses Azure Database for PostgreSQL, enable database monitoring in the PostgreSQL Terraform module:

```hcl
module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"

  # Existing configuration...

  azure_enable_monitoring = true
}
```

Depending on the service's existing infrastructure, this may require:

- an Azure Monitor resource
- a monitoring resource group
- diagnostic settings
- permissions for the monitoring workspace

Plan the Terraform changes before applying them and check whether enabling monitoring introduces any database changes or restarts.

## .NET services

The steps above use a Rails service as the example. A .NET service follows the same steps for Google Cloud, Key Vault secrets, PostgreSQL and the provider, with these differences.

Set these extra inputs on the Airbyte module:

| Input | Value | Notes |
| --- | --- | --- |
| `is_rails_application` | `false` | The module runs `rake dfe:analytics:airbyte_deploy_tasks` for Rails, so this must be turned off. |
| `is_dotnet_application` | `true` | Runs the .NET stream-update job instead. |
| `dotnet_application_directory` | For example `/Apps/TrsCli` or `/app` | The folder in the container image that holds the `dfe-analytics` directory. Check the service's Dockerfile. |
| `airbyte_sync_mode` | `incremental_deduped_history` | The default is `incremental_append`. Both existing .NET services use `incremental_deduped_history`. |
| `use_legacy_dotnet_shim` | `true` (default) or `false` | `true` runs `dfe-analytics/apply-config.sh`, which needs a shell in the image. `false` runs the `dfe-analytics` executable with `config apply --path dfe-analytics/db-config.json`. It needs no shell but needs a recent `DfeAnalytics.EFCore`. |
| `additional_policy_tags` | Map of alias to policy tag ID | Optional. TRS uses it for `sensitive_hidden`. |
| `skip_policy_tags` | `true` or `false` | Optional. Skips applying policy tags to BigQuery tables. |
| `gcp_dataset_internal` | For example `airbyte_internal` | Optional. Name of the internal Airbyte dataset. |

Use the `dfe-analytics-dotnet` library in the application and register it, for example `app.MapDfeAnalyticsDbConfiguration<YourDbContext>()` in teaching-record-system. Set the `DfeAnalytics__*` environment variables instead of the Rails `BIGQUERY_*` variables in step 11, and skip steps 12 and 13, because the .NET job does not use `AIRBYTE_CONFIGURATION` or the Rails initializer.

The container image must include the `dfe-analytics` directory (and `apply-config.sh` when `use_legacy_dotnet_shim` is `true`).

Examples: [teaching-record-system](https://github.com/DFE-Digital/teaching-record-system/blob/main/terraform/aks/airbyte.tf) and [check-performance-data](https://github.com/DFE-Digital/check-performance-data/blob/main/terraform/application/airbyte.tf).

> The .NET job receives the database connection string, Google credentials and Airbyte client secret as Kubernetes job arguments. They are visible in Terraform state and job metadata, so restrict access to both.

## Review apps

Review apps can run Airbyte so changes to it can be tested before a service rolls it out elsewhere. Examples: register-early-career-teachers-public and teacher-training-entitlement.

Set these in `config/terraform/application/config/review.tfvars.json` (or the service's equivalent), as booleans and not strings:

```json
{
  "pg_airbyte_enabled": true,
  "airbyte_enabled": true,
  "connection_status": "active"
}
```

Things to know:

- Each review app gets its own dataset, for example `<service_short>_airbyte_review_<PR number>`.
- The Airbyte database setup job fills the database before the app's migration job runs. `db:prepare` then replays every migration against tables that already exist and fails. Override the review app's migration command to `["exec", "rails", "db:schema:load", "db:migrate"]`.
- `db:schema:load` does not change enum types that already exist. If an earlier deploy half-migrated the database, delete the review app and redeploy, otherwise errors like a missing enum value remain.
- The stream-update job waits 60 seconds so migrations can create tables first. If it fails on a missing table (for example `relation "solid_queue_jobs" does not exist`), re-run the deploy.
- If the review app sets `create_bigquery_dataset` to `false`, the `dfe_analytics` module does not set the BigQuery and Workload Identity settings in the pod. Commands such as `DfE::Analytics::BigQueryApi.apply_policy_tags` then fail with a `ConfigurationError` listing the missing settings.
- Make sure the repository's Workload Identity Pool binding for `Airbyte_workflow_IAM` exists (step 3.5), otherwise the deploy fails with `403`.
- Use the `try()` provider pattern from step 7 so the review app can be deleted.

## Rollout order

Roll Airbyte out to one environment at a time. Some services set `pg_airbyte_enabled` without `airbyte_enabled`: logical replication is on but no connection exists. This is a valid state.

1. Set `pg_airbyte_enabled` to `true` and deploy in the agreed window. This can restart the PostgreSQL server several times.
2. Add the application environment variables and enable the Rails initializer for the environment.
3. Set `airbyte_enabled` to `true` and deploy. The connection is created inactive.
4. Set `connection_status` to `active`, deploy and validate in the Airbyte UI (step 15).

In tfvars files use JSON booleans (`true`, not `"true"`).

## Troubleshooting commands

### List Workload Identity Pools

```shell
gcloud iam workload-identity-pools list \
  --project=<PROJECT_ID> \
  --location=global
```

### List providers in a Workload Identity Pool

```shell
gcloud iam workload-identity-pools providers list \
  --project=<PROJECT_ID> \
  --location=global \
  --workload-identity-pool=<WORKLOAD_IDENTITY_POOL>
```

### Describe a provider

```shell
gcloud iam workload-identity-pools providers describe \
  <PROVIDER_NAME> \
  --project=<PROJECT_ID> \
  --location=global \
  --workload-identity-pool=<WORKLOAD_IDENTITY_POOL>
```

### List the BigQuery datasets

```shell
bq ls --project_id=<PROJECT_ID>
```

### Describe the internal Airbyte dataset

```shell
bq show \
  --format=prettyjson \
  <PROJECT_ID>:airbyte_internal
```

### Check the custom role

```shell
gcloud iam roles describe Airbyte_workflow_IAM \
  --project=<PROJECT_ID>
```

### Check the active Google Cloud configuration

```shell
gcloud config list
```

### Check application-default credentials

```shell
gcloud auth application-default print-access-token
```