# gh-actions

## GH Action Workflows on Google Cloud

This doco assumes that the workload identity federation has already been set up as per these [instructions](https://github.com/sam-nash/google_cloud/blob/master/docs/Workload_Identity_Federation.md).

### terraform workflows

This section will demonstrate how to use GitHub Actions with Workload Identity Federation to Apply a terraform plan.

Step 1 : Retrieve the Workload Identity Provider URI of your GCP project

```shell
gcloud iam workload-identity-pools providers describe gh-provider \
  --project=gh-actions-1506 \
  --location="global" \
  --workload-identity-pool=gh-pool \
  --format="value(name)"
```

**Output**
```projects/180855126385/locations/global/workloadIdentityPools/gh-pool/providers/gh-provider```

Step 2: Go to your GitHub repository settings, and add the following secrets in `settings/secrets/actions`:

- `GCP_PROJECT_ID`: Your Google Cloud project ID.
- `GCP_SERVICE_ACCOUNT`: The email of your Google Cloud service account.
- `GCP_WORKLOAD_IDENTITY_PROVIDER`: The URI of the WIF retrieved in the previous step.

Refer to the [screenshot] (GH_Variables.png)

Step 3 : Give the service account relevant permissions to access the target project
This must be run by an owner of the project

```sh
  gcloud projects add-iam-policy-binding sam-nash \
    --member="serviceAccount:ghactions-sa@gh-actions-1506.iam.gserviceaccount.com" \
    --role="roles/editor"
  ```

Step 4 : Create the GCS bucket and grant the service account permissions to write to the bucket

```sh
  # Set the project ID
  PROJECT_ID="sam-nash"

  # Set the bucket name
  BUCKET_NAME="${PROJECT_ID}-tfstate"

  # Set the service account email
  SERVICE_ACCOUNT_EMAIL="ghactions-sa@gh-actions-1506.iam.gserviceaccount.com"

  # Create the GCS bucket
  gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME

  # Grant the roles/storage.admin role to the service account
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"
    ```

In this target workflow:

The on: repository_dispatch event listens for terraform_plan and terraform_apply events.
The Checkout code step checks out the repository code.
The Authenticate to Google Cloud step uses the google-github-actions/auth@v2 action to authenticate to Google Cloud.
The Set up Google Cloud SDK step sets up the Google Cloud SDK.
The Set GCP Project step sets the target GCP project using the project_name from the client_payload.
The Set up Terraform step sets up Terraform using the hashicorp/setup-terraform@v1 action.
The Terraform Init step initializes Terraform with the backend configuration dynamically set based on the project name.
The Terraform Plan step runs the terraform plan command if the event action is terraform_plan.
The Post Plan Comment step posts the Terraform plan output as a comment on the pull request if the event action is terraform_plan.
The Terraform Apply step runs the terraform apply command if the event action is terraform_apply.
This workflow handles both the terraform_plan and terraform_apply events, performing the appropriate Terraform actions based on the event type and the payload received.

https://github.com/sam-nash/google_cloud/settings/actions

Workflow permissions
Choose the default permissions granted to the GITHUB_TOKEN when running workflows in this repository. You can specify more granular permissions in the workflow using YAML. Learn more about managing permissions.



Read and write permissions
Workflows have read and write permissions in the repository for all scopes.

### gcp docker runner

Give the relevant permissions to the service account

```sh
gcloud projects add-iam-policy-binding gh-actions-1506 \
    --member "serviceAccount:ghactions-sa@gh-actions-1506.iam.gserviceaccount.com" \
    --role "roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding gh-actions-1506 \
--member "serviceAccount:ghactions-sa@gh-actions-1506.iam.gserviceaccount.com" \
--role "roles/run.admin"
```
