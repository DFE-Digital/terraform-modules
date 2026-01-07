# Airbyte
Create resources in Azure and Google cloud for airbyte to send data to BigQuery

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

See https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/airbyte.md for a detailed overview of how Airbyte is being used.

Before using this module, the following must have already been completed.

### 1. Airbyte base resources

Each namespace has it's own airbyte base resources (airbyte ui, worker, cron, etc)
A Service will then have its own workspace within that namespace.

Ask the SD infra ops to either create the base resources or create a workspace as per https://github.com/DFE-Digital/teacher-services-cloud/tree/main/airbyte

Once created, the following secrets will need to be added to the infrastructure keyvault for the target environment
- AIRBYTE-CLIENT-ID
- AIRBYTE-CLIENT-SECRET
- AIRBYTE-WORKSPACE-ID

Also set a password for the database replication user
- AIRBYTE-REPLICATION-PASSWORD

### 2. Create these GCP resources if they don't already exist

Custom roles:

Airbyte_workflow_IAM with permissions (with id Airbyte_workflow_IAM)
- resourcemanager.projects.getIamPolicy
- resourcemanager.projects.setIamPolicy

BigQuery Appender Airbyte (with id bigquery_appender_airbyte)
- bigquery.datasets.get
- bigquery.tables.get
- bigquery.tables.updateData

BQ dataset:

A dataset for the internal airbyte raw tables with fixed name: airbyte_internal
- One required per BigQuery project
- The expiry on the table should be set to 1 day
- Encryption should be changed to the project Cloud KMS Key

```

bq --location=europe-west2 mk
–dataset
–default_kms_key projects/<PROJECT_ID>/locations/europe-west2/keyRings/<my-keyring>/cryptoKeys/<my-key>
–default_table_expiration 86400
–description “Airbyte internal table - Only for airbyte use”
<PROJECT_ID>:<DATASET_ID>

```

Workload identity pool:

For each project a workload identity pool with the name azure-cip-identity-pool should exist.

If this does not exist then one can be created with either the create gcp workload identity pool gcloud script at https://github.com/DFE-Digital/teacher-services-analytics-cloud/blob/main/scripts/gcloud/create-gcp-workload-identity-pool.sh or from the IAM gcloud console using the attributes specified in the gcloud script.

Workload identity pool provider:

For each project a workload identity pool with the name azure-cip-oidc-provider should exist.

If this does not exist then one can be created with either the create gcp workload identity pool provider gcloud script at https://github.com/DFE-Digital/teacher-services-analytics-cloud/blob/main/scripts/gcloud/create-gcp-workload-identity-pool-provider.sh or from the IAM gcloud console using the attributes specified in the gcloud script.

### 3. Configure the Postgres database to use logical replication
- note that this will trigger several restarts of the database server

Add to the database terraform definition in the service
```

module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"
  ...
  use_airbyte = var.pg_airbyte_enabled
}

# pg_airbyte_enabled used in the postgres module
variable "pg_airbyte_enabled" { default = false }

```

Then add "pg_airbyte_enabled": true to the env.tfvars.json to enable for an environment

### 4. Add the below to the service terraform to create the airbyte source, destination and connection and gcp resources

```hcl
provider "google" {
  project = "apply-for-qts-in-england" # change as required
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = local.app_resource_group_name
}

data "azurerm_key_vault_secret" "airbyte_client_id" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-CLIENT-ID"
}

data "azurerm_key_vault_secret" "airbyte_client_secret" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-CLIENT-SECRET"
}

data "azurerm_key_vault_secret" "airbyte_workspace_id" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-WORKSPACE-ID"
}

# change this to a random password?
data "azurerm_key_vault_secret" "airbyte_replication_password" {
  count = var.airbyte_enabled ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "AIRBYTE-REPLICATION-PASSWORD"
}

module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  service_name          = var.service_name
  docker_image          = var.app_docker_image
  postgres_version      = var.postgres_version
  postgres_url          = module.postgres.url

  host_name          = module.postgres.host
  database_name      = module.postgres.name
  workspace_id       = data.azurerm_key_vault_secret.airbyte_workspace_id[0].value
  client_id          = data.azurerm_key_vault_secret.airbyte_client_id[0].value
  client_secret      = data.azurerm_key_vault_secret.airbyte_client_secret[0].value
  repl_password      = data.azurerm_key_vault_secret.airbyte_replication_password[0].value
  server_url         = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
  connection_status  = var.connection_status

  cluster           = var.cluster
  namespace         = var.namespace
  gcp_taxonomy_id   = "69524444121704657" # change as required
  gcp_policy_tag_id = "6523652585511281766" # change as required
  gcp_keyring       = "bat-key-ring" # change as required
  gcp_key           = "bat-key" # change as required

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  use_azure = var.deploy_azure_backing_services
}

## Airbyte module variables

variable "airbyte_enabled" { default = false }

# pg_airbyte_enabled used in the postgres module
variable "pg_airbyte_enabled" { default = false }

variable "connection_status" {
  type = string
  default = "inactive"
  description = "Connectin status, either active or inactive"
}

terraform {
  required_version = "~> 1.9.8"
  required_providers {
    ...
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.10.0"
    }
  }
  ...

provider "airbyte" {
  # Configuration options
  server_url = var.airbyte_enabled ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}/api/public/v1" : ""
  client_id = var.airbyte_enabled ? data.azurerm_key_vault_secret.airbyte_client_id[0].value : ""
  client_secret = var.airbyte_enabled ? data.azurerm_key_vault_secret.airbyte_client_secret[0].value: ""
}
```

Once you add "airbyte_enabled": true to the env.tfvars.json this will then create the following
- airbyte source
- airbyte destination
- airbyte connection (by default inactive)
- initialise the database replication slot
- create gcp resources, including
  - service account
  - bigquery dataset

By default the Airbyte connection will be inactive
Add "connection_status": "active" to the env.tfvars.json to enable

### 5. Log into the ui to check all looks ok
- https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}/workspaces/${var.workspace_id}

### 6. Enable monitoring for the database server if using Azure Postgresql
- set azure_enable_monitoring = true in the terraform for the postgres module
- this may require a new resource group and azure monitor to be created

## Authentication - Command line
The user should have Owner role on the Google project.

- Run `gcloud auth application-default login`
- Run terraform

## Authentication - Github actions
Github action workflows use workload identity federation to authenticate to Google. Use the `authorise_workflow.sh` script to set it up, once per repository. The Owner role is required.

- Run the `authorise_workflow.sh` located in this terraform module, under *aks/dfe_analytics*:
  ```
  ./authorise_workflow.sh PROJECT_ID REPO
  ```
  Example:
  ```
  ./authorise_workflow.sh apply-for-qts-in-england apply-for-qualified-teacher-status
  ```
- The script shows the *permissions* and *google-github-actions/auth step* to add to the workflow job e.g.:
  ```
  deploy_job:
    permissions:
      id-token: write
      ...
  ```
  ```
  steps:
  ...
  - uses: google-github-actions/auth@v2
    with:
      project_id: teaching-qualifications
      workload_identity_provider: projects/708780292301/locations/global/workloadIdentityPools/check-childrens-barred-list/providers/check-childrens-barred-list
  ```
- :warning: Adding the permission removes the [default token permissions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication#permissions-for-the-github_token), which may be an issue for some actions that rely on them. For example, the [marocchino/sticky-pull-request-comment](https://github.com/marocchino/sticky-pull-request-comment) action requires `pull-requests: write`. It must then be added explicitly.
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
