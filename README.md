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
