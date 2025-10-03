#!/usr/bin/env bash
# Set up Direct Workload Identity Federation
# See https://github.com/google-github-actions/auth?tab=readme-ov-file#preferred-direct-workload-identity-federation

PROJECT_ID=$1
REPO=$2

if [[ -z "$PROJECT_ID" || -z "$REPO" ]]; then
  cat <<EOF
Set up Direct Workload Identity Federation between Github action workflows from a repository and GCP for setting up Bigquery. The user must have the 'Owner' role on the project.
Usage: ./authorise_workflow.sh PROJECT_ID REPO - Example: ./authorise_workflow.sh apply-for-qts-in-england apply-for-qualified-teacher-status
EOF
  exit 1
fi

set -eu

GITHUB_ORG=DFE-Digital
ORG_REPO=${GITHUB_ORG}/${REPO}
# The pool name must be up to 32 characters
WORKLOAD_ID="${REPO:0:32}"

bind_role() {
  ROLE=$1
  echo "Bind role roles/${ROLE}"
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --role="${ROLE}" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${ORG_REPO}"
}

echo Login to Google cloud. The user must have the Owner role on the project.
gcloud auth application-default login

echo "Create ${WORKLOAD_ID} workload identity pool"
gcloud iam workload-identity-pools create "${WORKLOAD_ID}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="${WORKLOAD_ID}"

WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe "${WORKLOAD_ID}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)")

echo WORKLOAD_IDENTITY_POOL_ID=$WORKLOAD_IDENTITY_POOL_ID

echo "Create ${WORKLOAD_ID} workload identity pool provider"
gcloud iam workload-identity-pools providers create-oidc "${WORKLOAD_ID}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WORKLOAD_ID}" \
  --display-name="${WORKLOAD_ID}" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner == '${GITHUB_ORG}' && attribute.repository == '${ORG_REPO}' " \
  --issuer-uri="https://token.actions.githubusercontent.com"

echo Get workload identity pool provider id
WORKLOAD_IDENTITY_POOL_PROVIDER_ID=$(gcloud iam workload-identity-pools providers describe "${WORKLOAD_ID}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WORKLOAD_ID}" \
  --format="value(name)")

bind_role roles/iam.serviceAccountAdmin
bind_role roles/bigquery.dataOwner
bind_role roles/datacatalog.viewer
bind_role roles/cloudkms.viewer
# require this custom role for the wif to add the roles/bigquery.jobUser to the service account
# it's a custom role which needs to have been created manually in the project beforehand
bind_role projects/${$PROJECT_ID}/roles/Airbyte_workflow_IAM

echo
echo Now add this step to the workflow to authenticate to Google:
cat <<EOF
deploy_job:
  permissions:
    id-token: write
    ...
...
  steps:
  - uses: google-github-actions/auth@v2
    with:
      project_id: ${PROJECT_ID}
      workload_identity_provider: ${WORKLOAD_IDENTITY_POOL_PROVIDER_ID}
EOF
