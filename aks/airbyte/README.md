# Airbyte
Create resources in Azure and Google cloud for airbyte to send data to BigQuery

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

# Configure a service to use Airbyte

This guide explains how to configure a service to replicate data from Azure PostgreSQL to Google BigQuery using Airbyte.

## Overview

The setup consists of:

1. Authenticating with Google Cloud.
2. Checking the existing Google Cloud resources.
3. Creating any missing Google Cloud resources.
4. Creating the Airbyte base resources and workspace.
5. Adding the required secrets to Azure Key Vault.
6. Configuring PostgreSQL logical replication.
7. Adding the Airbyte Terraform configuration.
8. Configuring GitHub Actions authentication.
9. Deploying and enabling the Airbyte connection.
10. Validating the connection in the Airbyte UI.
11. Enabling PostgreSQL monitoring.

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

### 2.9 Check the legacy custom role

> **Note:** The `Airbyte_workflow_IAM` custom role is no longer required for new services. Only check or create it when supporting an existing service that still depends on it.

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

If it does not exist, the command returns `NOT_FOUND`.

Do not create this role for a new service.

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


```shell
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member="principalSet://iam.googleapis.com/projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<WORKLOAD_IDENTITY_POOL>/attribute.repository/DFE-Digital/<REPOSITORY_NAME>" \
  --role="projects/<PROJECT_ID>/roles/Airbyte_workflow_IAM"
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

Some services retrieve the Airbyte credentials from the application Key Vault. In those services, only `AIRBYTE-CLIENT-ID` and `AIRBYTE-CLIENT-SECRET` may need to be added there.

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

The service account names vary, but commonly begin with `app-wif`.

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
  required_version = "~> 1.9.8"

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
  server_url = var.airbyte_enabled ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}/api/public/v1" : ""

  client_id = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-ID : ""

  client_secret = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-SECRET : ""
}
```

If it is not already configured, add the Google provider:

```hcl
provider "google" {
  project = "<PROJECT_ID>"
}
```

Replace `<PROJECT_ID>` with the service's Google Cloud project ID.

## 8. Add the Airbyte module

Add the Airbyte module to the service Terraform configuration.

Values marked with placeholders must be replaced with the values discovered in #2-check-the-existing-google-cloud-resources.

```hcl
module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = var.environment
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

  server_url = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"

  connection_status  = var.connection_status
  connection_streams = local.connection_streams

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

The provider block and some variable names may already exist or may be implemented differently in the service. Search the repository and follow the existing conventions where they differ.

## 9. Add the Airbyte variables and locals

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
  connection_streams = var.airbyte_enabled
    ? file("workspace_variables/airbyte_stream_config.json")
    : null

  gcp_dataset_name = replace(
    "${var.service_short}_airbyte_${local.app_name_suffix}",
    "-",
    "_"
  )
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

## 10. Add the Airbyte stream configuration

If DFE_analytics > 1.16 this can be skipped

Create:

```text
workspace_variables/airbyte_stream_config.json
```

Define the tables and streams that Airbyte should replicate.

The exact contents depend on the service schema and should be agreed with the service team.

The file is loaded by:

```hcl
connection_streams = var.airbyte_enabled
  ? file("workspace_variables/airbyte_stream_config.json")
  : null
```

## 11. Add the application environment variables

Merge the following values into the service's application environment variables.

The exact implementation depends on how the service constructs its ConfigMap or environment variable map.

```hcl
{
  BIGQUERY_AIRBYTE_DATASET = var.airbyte_enabled
    ? local.gcp_dataset_name
    : null

  AIRBYTE_SERVER_URL = var.airbyte_enabled
    ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
    : null

  BIGQUERY_HIDDEN_POLICY_TAG = var.airbyte_enabled
    ? "projects/<PROJECT_ID>/locations/europe-west2/taxonomies/<TAXONOMY_ID>/policyTags/<POLICY_TAG_ID>"
    : null

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

Merge the following into the service's secret environment variables:

```hcl
{
  AIRBYTE_CONFIGURATION = var.airbyte_enabled ? jsonencode({
    SOURCE_ID      = module.airbyte[0].airbyte_source_id
    DESTINATION_ID = module.airbyte[0].airbyte_destination_id
    CONNECTION_ID  = module.airbyte[0].airbyte_connection_id
  }) : null
}
```

This makes the Airbyte resource IDs available to the application.


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

## 17. Enable PostgreSQL monitoring

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

### Check the legacy custom role

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