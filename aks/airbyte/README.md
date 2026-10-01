# Airbyte
Create resources in Azure and Google cloud for airbyte to send data to BigQuery

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

See https://github.com/DFE-Digital/dfe-analytics/blob/main/docs/airbyte.md for a detailed overview of how Airbyte is being used.

Before using this module, the following must have already been completed.

### 1. Airbyte base resources

Each namespace has it's own airbyte base resources (airbyte ui, worker, cron, etc).

A Service will then have its own connection within that namespace.

Ask the SD infra ops to either create the base resources or create a workspace as per https://github.com/DFE-Digital/teacher-services-cloud/tree/main/airbyte


### 2. Create secrets in the relevant Azure Key Vault.
Once the base resources have ben created, the following secrets will need to be added to the infrastructure Azure Key Vault for the target environment. Some services require the secrets set up in their app Key Vault too.
For example s189p01-rtt-pd-kv for rtt production but s189p01-ittms-pd-inf-kv for ittms production.

- AIRBYTE-CLIENT-ID - Airbyte UI -> Settings->Applications->Client ID
- AIRBYTE-CLIENT-SECRET - Airbyte UI -> Settings->Applications->Client Secret
- AIRBYTE-WORKSPACE-ID - The part of the URL before /settings
- AIRBYTE-REPLICATION-PASSWORD -  Create one. Follow the standards used by other accounts.
- AIRBYTE-BQ-SA - GCP -> IAM and admin->Service accounts -> email address in full. These can vary wildly but generally start `app-wif`.

### 3. Create these GCP resources if they don't already exist

To log into GCP see [below](#google-cloud-authentication)

#### Custom roles:

Airbyte_workflow_IAM with permissions (with id Airbyte_workflow_IAM)
- resourcemanager.projects.getIamPolicy
- resourcemanager.projects.setIamPolicy
- datacatalog.taxonomies.getIamPolicy
- datacatalog.taxonomies.setIamPolicy

```
gcloud iam roles create Airbyte_workflow_IAM \
  --project=rugged-abacus-218110 \
  --title="Airbyte Workflow IAM" \
--description="Created on: 2026-09-15" \
  --permissions="resourcemanager.projects.getIamPolicy,resourcemanager.projects.setIamPolicy,datacatalog.taxonomies.getIamPolicy,datacatalog.taxonomies.setIamPolicy" \
  --stage=ALPHA
```

NOTE: This custom role is no longer needed so ignore for new services.
BigQuery Appender Airbyte (with id bigquery_appender_airbyte)
- bigquery.datasets.get
- bigquery.tables.get
- bigquery.tables.updateData

#### BQ dataset:

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

#### Workload identity pool:

For each project a workload identity pool with the name azure-cip-identity-pool should exist.

If this does not exist then one can be created with either the create gcp workload identity pool gcloud script at https://github.com/DFE-Digital/teacher-services-analytics-cloud/blob/main/scripts/gcloud/create-gcp-workload-identity-pool.sh or from the IAM gcloud console using the attributes specified in the gcloud script.

Workload identity pool provider:

For each project a workload identity pool with the name azure-cip-oidc-provider should exist.

If this does not exist then one can be created with either the create gcp workload identity pool provider gcloud script at https://github.com/DFE-Digital/teacher-services-analytics-cloud/blob/main/scripts/gcloud/create-gcp-workload-identity-pool-provider.sh or from the IAM gcloud console using the attributes specified in the gcloud script.

### 4. Configure the Postgres database to use logical replication
- NOTE: that this will trigger several restarts of the database server. Agree a time to merge the PR with the service technical lead.

Add the following variable to the variables.tf
```
# pg_airbyte_enabled used in the postgres module
variable "pg_airbyte_enabled" { default = false }

```
Add to the database terraform definition in the service
```
module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"
  ...
  use_airbyte = var.pg_airbyte_enabled
}
```

Add the following to the env.tfvars.json to enable for an environment
```
"pg_airbyte_enabled": true
```

### 5. Add the below to the service terraform to create the airbyte source, destination and connection and gcp resources

- The provider block may or may not already be defined depending on the service.
- Other variables may be configured differently which should be outlined by your IDE. Search the code to find how they're configured.
- Remove the ` # change as required` comments once copied over.

```hcl
provider "google" {
  project = "apply-for-qts-in-england" # change as required
}

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

  host_name          = module.postgres.host
  database_name      = module.postgres.name
  workspace_id       = var.airbyte_enabled ? module.secrets.map.AIRBYTE-WORKSPACE-ID : null
  client_id          = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-ID : null
  client_secret      = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-SECRET : null
  repl_password      = var.airbyte_enabled ? module.secrets.map.AIRBYTE-REPLICATION-PASSWORD : null
  server_url         = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
  connection_status  = var.connection_status
  connection_streams = local.connection_streams

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
  gcp_bq_sa = var.airbyte_enabled ? module.secrets.map.AIRBYTE-BQ-SA : null
}

## Airbyte module variables

variable "airbyte_enabled" { default = false }

variable "connection_status" {
  type = string
  default = "inactive"
  description = "Connection status, either active or inactive"
}

locals {
  connection_streams = var.airbyte_enabled ? file("workspace_variables/airbyte_stream_config.json") : null
  gcp_dataset_name   = replace("${var.service_short}_airbyte_${local.app_name_suffix}", "-", "_")
}

module "secrets" {
  source = "./vendor/modules/aks//aks/secrets"

  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
}
```


#### Merge the following into env variables

The exact method will depend of the service.

```
{
  BIGQUERY_AIRBYTE_DATASET                    = var.airbyte_enabled ? local.gcp_dataset_name : null
  AIRBYTE_SERVER_URL                          = var.airbyte_enabled ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}" : null
  BIGQUERY_HIDDEN_POLICY_TAG                  = var.airbyte_enabled ? "projects/rugged-abacus-218110/locations/europe-west2/taxonomies/69524444121704657/policyTags/6523652585511281766" : null
  AIRBYTE_INTERNAL_DATASET                    = var.airbyte_enabled ? "${local.gcp_dataset_name}_internal" : null
}
```

#### Merge the following into secret variables

The exact method will depend of the service.

```
{
  AIRBYTE_CONFIGURATION = var.airbyte_enabled ? jsonencode({
  SOURCE_ID      = module.airbyte[0].airbyte_source_id
  DESTINATION_ID = module.airbyte[0].airbyte_destination_id
  CONNECTION_ID  = module.airbyte[0].airbyte_connection_id
  }) : null
}
```
#### Add to terraform.tf

```
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

airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.10.0"
    }

provider "airbyte" {
  # Configuration options
  server_url = var.airbyte_enabled ? "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}/api/public/v1" : ""
  client_id = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-ID : ""
  client_secret = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-SECRET : ""
}
```

### 6. Enable Airbyte

Add the following to env.tfvars.json.

```hcl
"airbyte_enabled": true,
"connection_status": "active"
```


Once you've added `"airbyte_enabled": true` to the env.tfvars.json this will then create the following
- airbyte source
- airbyte destination
- airbyte connection (by default inactive)
- initialise the database replication slot
- create gcp resources, including
  - service account
  - bigquery dataset

By default the Airbyte connection will be inactive.
Add `"connection_status": "active"` to the env.tfvars.json to enable it.

### 7. Log into the ui to check all looks ok

- Go to our Airbyte Loop document for the structure and exact URLs.
- Select the relevant connection.
- Select the Schema tab.
- If tables are selected with a blue/white tick click the `Sync now` button.
- If no tables are selected, select the `airbyte_heartbeat` table and click the `Sync now` button.

### 8. Enable monitoring for the database server if using Azure Postgresql

- set azure_enable_monitoring = true in the terraform for the postgres module
- this may require a new resource group and azure monitor to be created


### 9. Create Airbyte Config File

Add a new file to our terraform config named `airbyte_stream_config.json`
For example `terraform/application/config/airbyte_stream_config.json`

### 9. Creating a Review App

Before deploying Airbyte to an environment, you should create a Review App to ensure all necessary integration with the services applications are covered.

-  Add the following section to any Workflows involved in deploying and managing review apps. It needs to fit in the steps section
```
      - name: Set Airbyte
        if: (contains(github.event.pull_request.labels.*.name, 'airbyte'))
        run: |
          echo "TF_VAR_pg_airbyte_enabled=true" >> $GITHUB_ENV
          echo "TF_VAR_airbyte_enabled=true" >> $GITHUB_ENV
          echo "TF_VAR_connection_status=active" >> $GITHUB_ENV
```
- Add the following section to the Makefile
```
airbyte: ## Add airbyte for review apps
	$(if $(PR_NUMBER), , $(error Missing environment variable "PR_NUMBER", Please specify a pr number for your review app))
	$(eval export TF_VAR_pg_airbyte_enabled=true)
	$(eval export TF_VAR_airbyte_enabled=true)
	$(eval export TF_VAR_connection_status=active)
```
- Add the following variable to the review.tfvars.json file.
```
"pg_airbyte_enabled": true
```
- Create a PR and add the GitHub label `airbyte`. If the label does not exist, create one with `Edit labels` and a description of `Required for Airbyte in a review app`
- Add the devops label and add the deploy label  if necessary.

### 10. Deploying to an Environment

When the PR is ready and the you're confident Airbyte can be enabled in an environment, you must deploy manually rather than merging the PR.



## Google Cloud Authentication

The user must have the Owner role on the Google project.

- Run `gcloud auth application-default login`

## Github actions Authentication

Github action workflows use workload identity federation to authenticate to Google.

Use the `authorise_workflow.sh` script to set it up, once per repository. The Owner role is required.

- Run the `authorise_workflow.sh` located in this terraform module, under *aks/dfe_analytics*:
  ```
  ./authorise_workflow.sh <PROJECT_ID> <REPO>
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

## Additional Google Cloud Resources

The following resources are all required. Some may have already been created whilst others may not have.

### Login (Authenticate)
```
gcloud auth application-default login
```
- Click the link provided
- Select your DfE email address
- Select Continue
- Select Continue
- Copy the provided code and paste into your terminal

### Checking resources

The user must have Owner role on the Google project.

#### List projects

`gcloud projects list`

#### Select project

`gcloud config set project <Project ID>`

#### Get project taxonomy
  ```
  gcloud data-catalog taxonomies list --location=europe-west2 --format="value(name)"
  ```

  The path contains the taxonomy id as a number e.g. taxonomies/nnnnnnnnnnnnnnnnnnn

#### Get policy tags
  ```
  gcloud data-catalog taxonomies policy-tags list --taxonomy="projects/<Project ID>/locations/europe-west2/taxonomies/nnnnnnnnnnnnnnnnnnn" --location="europe-west2" --filter="displayName:hidden" --format="value(name)"
  ```

  The path contains the policy tag id as a number e.g. 2399328962407973209

#### Get GCP Keyring

`gcloud kms keyrings list --location=europe-west2 --project=<Project ID>`

#### Get GCP Key

`gcloud kms keys list --location=europe-west2 --keyring=<Keyring from above> --project=<Project ID>`

#### List Workload Identity Pools (WIP) for a Project

`gcloud iam workload-identity-pools list --project=<Project ID> --location=global`

#### WIP Providers for a WIP

This is the value that goes in the GitHub variable gcp-wip
```
gcloud iam workload-identity-pools providers list \
 --project=<Project ID> \
 --location=global \
 --workload-identity-pool=<WIP from above>
```

#### Custom Roles
`gcloud iam roles describe Airbyte_workflow_IAM --project=<Project ID>`

The response will either be
```
description: 'Created on: 2025-09-24'
etag: BwZYx499999=
includedPermissions:
- datacatalog.taxonomies.getIamPolicy
- datacatalog.taxonomies.setIamPolicy
- resourcemanager.projects.getIamPolicy
- resourcemanager.projects.setIamPolicy
name: projects/<Project ID>/roles/Airbyte_workflow_IAM
stage: ALPHA
title: Airbyte workflow IAM
```

Or

```
ERROR: (gcloud.iam.roles.describe) NOT_FOUND: The role named projects/<Project ID>/roles/Airbyte_workflow_IAM was not found. This command is authenticated as first.surname@plop.gov.uk which is the active account specified by the [core/account] property.
```
#### BQ Dataset (Look for airbyte_internal)

```bq ls --project_id=get-into-teaching```

### Creating Google Cloud Resources

#### Work Identity Pool

```
  gcloud iam workload-identity-pools create "azure-cip-identity-pool" \
   --location="global" \
   --description="Azure CIP -> GCP Workload identity pool" \
   --display-name="azure-cip-identity-pool" \
   --project=<Project ID>
```

#### Work Identity Pool Provider

```
  gcloud iam workload-identity-pools providers create-oidc azure-cip-oidc-provider \
   --workload-identity-pool="azure-cip-identity-pool" \
   --issuer-uri="https://login.microsoftonline.com/9c7d9dd3-840c-4b3f-818e-552865082e16/v2.0" \
   --allowed-audiences="fb60f99c-7a34-4190-8149-302f77469936" \
   --location="global" \
   --attribute-mapping="google.subject=assertion.sub" \
   --project=<Project ID>
```

#### Custom Roles

```
gcloud iam roles create Airbyte_workflow_IAM \
  --project=<Project ID> \
  --title="Airbyte Workflow IAM" \
--description="Created on: 2026-09-15" \
  --permissions="resourcemanager.projects.getIamPolicy,resourcemanager.projects.setIamPolicy,datacatalog.taxonomies.getIamPolicy,datacatalog.taxonomies.setIamPolicy" \
  --stage=ALPHA
```

#### BQ Dataset (airbyte_internal)

```
bq --location=europe-west2 mk \
  --dataset \
  --default_kms_key=projects/<Project ID>/locations/europe-west2/keyRings/<key-ring>/cryptoKeys/<key> \
  --default_table_expiration=86400 \
  --description="Airbyte internal table - Only for airbyte use" \
  <Project ID>:airbyte_internal
```
