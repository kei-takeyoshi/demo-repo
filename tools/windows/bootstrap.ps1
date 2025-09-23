param(
  [string]$PROJECT_ID = "XXX",
  [string]$REGION = "asia-northeast1",
  [string]$ZONE = "asia-northeast1-a",
  [string]$REPO = "demo-repo",
  [string]$CLUSTER = "demo-gke",
  [string]$NAMESPACE = "demo",
  [string]$SA_NAME = "github-actions-deployer",
  [string]$REPO_ID = "OWNER/REPO",
  [string]$POOL_ID = "github-pool",
  [string]$PROVIDER_ID = "github-provider"
)
$ErrorActionPreference = "Stop"
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com artifactregistry.googleapis.com iamcredentials.googleapis.com
gcloud artifacts repositories create $REPO --repository-format=docker --location=$REGION --description="Spring Boot demo images" 2>$null
gcloud container clusters create $CLUSTER --zone $ZONE --num-nodes 1 --workload-pool="$PROJECT_ID.svc.id.goog"
kubectl create namespace $NAMESPACE 2>$null
$SA_EMAIL = "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
gcloud iam service-accounts create $SA_NAME --display-name="GitHub Actions Deployer" 2>$null
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/artifactregistry.writer"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="roles/container.admin"
gcloud iam workload-identity-pools create $POOL_ID --project=$PROJECT_ID --location="global" --display-name="GitHub OIDC Pool" 2>$null
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID --project=$PROJECT_ID --location="global" --workload-identity-pool=$POOL_ID --display-name="GitHub OIDC Provider" --issuer-uri="https://token.actions.githubusercontent.com" --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" 2>$null
gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/$PROJECT_ID/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/$REPO_ID"
gcloud container clusters get-credentials $CLUSTER --zone $ZONE
Write-Host "Bootstrap complete." -ForegroundColor Green
