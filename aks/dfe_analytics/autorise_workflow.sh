PROJECT_ID=apply-for-qts-in-england
GITHUB_ORG=DFE-Digital
REPO=apply-for-qualified-teacher-status
ORG_REPO=${GITHUB_ORG}/${REPO}

echo Login to Google cloud. The user must have the Owner role on the project.
gcloud auth application-default login

# The pool name must be up to 32 characters
WORKLOAD_ID="${REPO:0:32}"

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

echo Bind role roles/iam.securityAdmin
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --role="roles/iam.securityAdmin" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${ORG_REPO}"

echo Bind role roles/bigquery.admin
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --role="roles/bigquery.admin" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${ORG_REPO}"

echo Bind role roles/dataplex.taxonomyViewer
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --role="roles/dataplex.taxonomyViewer" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${ORG_REPO}"

echo Bind role roles/cloudkms.viewer
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --role="roles/cloudkms.viewer" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${ORG_REPO}"

echo
echo Now add this step to the workflow to authenticate to Google:
cat <<EOF
deploy_job:
    permissions:
      contents: read
      id-token: write
...
    steps:
    - uses: google-github-actions/auth@v2
        with:
            project_id: ${PROJECT_ID}
            workload_identity_provider: ${WORKLOAD_IDENTITY_POOL_PROVIDER_ID}
EOF
